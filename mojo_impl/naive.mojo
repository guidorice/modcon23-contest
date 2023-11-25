import benchmark
from math.limit import inf, neginf
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
 
    alias NegInf = neginf[dtype]()
    alias Inf = inf[dtype]()
    let num_features = tensor.shape()[1]
    var result = SIMD[dtype, 2 * dims]()

    for d in range(dims):
        result[d] = Inf

    for d in range(dims, 2 * dims):
        result[d] = NegInf

    for y in range(dims):
        for x in range(num_features):
            let val = tensor[Index(y, x)]
            if val < result[y]:
                result[y] = val
            if val > result[dims + y]:
                result[dims + y] = val

    return result


fn main() raises:
    let width = atol(argv()[1])
    alias dtype = DType.float32
    alias dims = 2

    print(dtype, width)

    let spec = TensorSpec(dtype, dims, width)
    let tensor = rand[dtype](spec)

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