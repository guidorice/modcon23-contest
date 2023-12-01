import benchmark
from math.limit import inf, neginf, max_finite, min_finite
from random import rand
from sys import argv
from tensor import Tensor, TensorSpec
from utils.index import Index

fn envelope[dtype: DType, dims: Int](tensor: Tensor[dtype]) -> SIMD[dtype, 2 * dims]:
    """
    Calculate envelope: iterative, plain mojo code. Uses static types and a stdlib numeric container type (Tensor).
    """

    @parameter
    constrained[dims > 0 and dims % 2 == 0, "power-of-two dims only"]()
 
    let num_features = tensor.shape()[1]
    var result = SIMD[dtype, 2 * dims]()

    @parameter
    if dtype.is_floating_point():
        let min_start = inf[dtype]()
        let max_start = neginf[dtype]()
        @unroll
        for d in range(dims):
            result[d] = min_start
        @unroll
        for d in range(dims, 2 * dims):
            result[d] = max_start
    else:  # integral types
        let min_start = max_finite[dtype]()
        let max_start = min_finite[dtype]()
        @unroll
        for d in range(dims):
            result[d] = min_start
        @unroll
        for d in range(dims, 2 * dims):
            result[d] = max_start

    for y in range(dims):
        for x in range(num_features):
            let val = tensor[Index(y, x)]
            if val < result[y]:
                result[y] = val
            if val > result[dims + y]:
                result[dims + y] = val

    return result

alias dtype = DType.float64
alias dims = 2

fn main() raises:
    """
    Usage: `mojo naive.mojo {n}` , where n is an integer number of features.
    """

    # read number of features
    let width = atol(argv()[1])

    # create a tensor, filled with random values
    print(dtype, width)
    let spec = TensorSpec(dtype, dims, width)
    let tensor = rand[dtype](spec)

    # run benchmark module
    @parameter
    fn envelope_worker():
        _ = envelope[dtype, dims](tensor)

    let mojo_report = benchmark.run[envelope_worker]()
    mojo_report.print()
    let secs = mojo_report.mean["s"]()
    let ns = mojo_report.mean["ns"]()
    let ms = mojo_report.mean["ms"]()
    print("ns:", ns)
    print("microsecs:", secs * 10 ** 6)
    print("ms:", ms)
    print("s:", secs)
    print()
