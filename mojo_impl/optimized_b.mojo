import benchmark
from algorithm import vectorize
from algorithm.functional import parallelize
from math.limit import inf, neginf
from random import rand
from sys import argv
from sys.info import simdbitwidth
from tensor import Tensor, TensorSpec
from utils.index import Index


fn envelope[dtype: DType, dims: Int](tensor: Tensor[dtype]) -> SIMD[dtype, 2 * dims]:
    """
    Calculate envelope: parallelized, vectorized, unrolled.
    """
    @parameter
    constrained[dims > 0 and dims % 2 == 0, "power-of-two dims only"]()
 
    alias nelts = simdbitwidth()
    alias NegInf = neginf[dtype]()
    alias Inf = inf[dtype]()
    let num_features = tensor.shape()[1]

    var result = SIMD[dtype, 2 * dims]()

    @unroll
    for d in range(dims):
        result[d] = Inf

    @unroll
    for d in range(dims, 2 * dims):
        result[d] = NegInf

    @parameter
    fn min_max_task(dim: Int):
        @parameter
        fn min_max_simd[simd_width: Int](feature_idx: Int):
            let index = Index(dim, feature_idx)
            let vals = tensor.simd_load[simd_width](index)
            let min = vals.reduce_min()
            if min < result[dim]:
                result[dim] = min
            let max = vals.reduce_max()
            if max > result[dims + dim]:
                result[dims + dim] = max

        vectorize[nelts, min_max_simd](num_features)

    parallelize[min_max_task](dims)

    return result


fn main() raises:
    let width = atol(argv()[1])
    alias dtype = DType.float32
    alias dims = 2
    print(dtype, width)
    
    let spec = TensorSpec(dtype, dims, width)
    let tensor = rand[dtype](spec)
    let res = envelope[dtype, dims](tensor)

    @parameter
    fn envelope_worker():
        _ = envelope[dtype, dims](tensor)

    let mojo_report = benchmark.run[envelope_worker]()
    mojo_report.print()
    let secs = mojo_report.mean["s"]()
    print("ns:", secs * 10 ** 9)
    print("microsecs:", secs * 10 ** 6)
    print("ms:", secs * 10 ** 3)
    print("s:", secs)