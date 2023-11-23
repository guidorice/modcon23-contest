from utils.index import Index
from math.limit import inf, neginf
from sys.info import simdwidthof, simdbitwidth
from algorithm import vectorize
from algorithm.functional import parallelize
import math
from tensor import Tensor, TensorSpec
from memory import stack_allocation
from random import rand
import benchmark
from autotune import autotune, search

alias dtype = DType.float32
alias dims = 2
alias EnvelopeFnType = fn(tensor: Tensor[dtype], inout result: SIMD[dtype, 4]) -> None


@adaptive
fn envelope_impl(tensor: Tensor[dtype], inout result: SIMD[dtype, 4]):
    """
    TODO docstring.
    """

    @parameter
    constrained[dims % 2 == 0, "power-of-two dims only"]()
    
    alias w = simdwidthof[dtype]()
    alias nelts = autotune(2, 4, 8, 16, 32, 64, 128)
    let parallelize_threshold: Int = 0
    let parallelize_num_workers: Int = 0

    alias NegInf = neginf[dtype]()
    alias Inf = inf[dtype]()
    let num_features = tensor.shape()[1]
    var result_tensor = Tensor[dtype](2 * dims, 1)

    @unroll
    for d in range(dims):
        result_tensor[d] = Inf  # min (southwest) values, start from inf.

    @unroll
    for d in range(dims, 2 * dims):
        result_tensor[d] = NegInf  # max (northeast) values, start from neginf

    # vectorized load and min/max calculation for each of the dims
    @parameter
    fn min_max_task(dim: Int):
        @parameter
        fn min_max_simd[simd_width: Int](feature_idx: Int):
            let index = Index(dim, feature_idx)
            let vals = tensor.simd_load[simd_width](index)
            let min = vals.reduce_min()
            if min < result_tensor[dim]:
                result_tensor[dim] = min
            let max = vals.reduce_max()
            if max > result_tensor[dims + dim]:
                result_tensor[dims + dim] = max

        vectorize[nelts, min_max_simd](num_features)

    if num_features >= parallelize_threshold:
        parallelize[min_max_task](dims, parallelize_num_workers)
    else:
        for d in range(dims):
            min_max_task(d)

    result = result_tensor.simd_load[4]()


fn elementwise_evaluator(
    fns: Pointer[EnvelopeFnType],
    num: Int,
) -> Int:
    print("elementwise_evaluator, number of candidates: ", num)

    alias height = 4
    let width = 100000
    let spec = TensorSpec(dtype, height, width)
    let tensor = rand[dtype](spec)
    var best_idx: Int = -1
    var best_time: Int = -1
    for i in range(num):
        @parameter
        fn wrapper():
            var result: SIMD[dtype, 4] = 0
            let fn_impl = fns.load(i)
            _ = fn_impl(tensor, result)

        let cur_time = benchmark.run[wrapper](1).mean["ns"]().to_int()
        if best_idx < 0 or best_time > cur_time:
            best_idx = i
            best_time = cur_time

        print("time[", i, "] =", cur_time)

    print("selected:", best_idx)
    return best_idx


fn envelope(tensor: Tensor[dtype], inout result: SIMD[dtype, 4]):
    alias best_impl: EnvelopeFnType
    search[
      fn_type=EnvelopeFnType,
      candidates=VariadicList(envelope_impl.__adaptive_set),
      evaluator=elementwise_evaluator -> best_impl,
    ]()
    best_impl(tensor, result)

fn main():
    alias height = 4
    let width = 100000
    let spec = TensorSpec(dtype, height, width)
    let tensor = rand[dtype](spec)
    var result: SIMD[dtype, 4] = 0
    envelope(tensor, result)
    print(result)
