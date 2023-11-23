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

alias dims = 2
alias result_len = 2 * dims

fn envelope[dtype: DType, dims: Int](tensor: Tensor[dtype]) -> SIMD[dtype, result_len]:

    @parameter
    constrained[dims > 0 and dims % 2 == 0, "power-of-two dims only"]()
 
    alias nelts = simdwidthof[dtype]()
    alias NegInf = neginf[dtype]()
    alias Inf = inf[dtype]()

    let parallelize_threshold: Int = 0
    let parallelize_num_workers: Int = dims
    let num_features = tensor.shape()[1]
    var result_tensor = Tensor[dtype](result_len, 1)

    @unroll
    for d in range(dims):
        result_tensor[d] = Inf

    @unroll
    for d in range(dims, 2 * dims):
        result_tensor[d] = NegInf

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

    return result_tensor.simd_load[result_len]()

from python import Python, PythonObject
from testing import assert_true

fn main() raises:
    alias dtype = DType.float32
    alias dims = 2
    let width = 1000

    let spec = TensorSpec(dtype, dims, width)
    let tensor = rand[dtype](spec)

    var env_result: SIMD[dtype, result_len] = 0

    @parameter
    fn envelope_worker():
        env_result = envelope[dtype, dims](tensor)

    let envelope_report = benchmark.run[envelope_worker]()
    envelope_report.print()

    let shapely = Python.import_module("shapely")

    fn shapely_multipoint_from_tensor(tensor: Tensor[dtype]) raises -> PythonObject:
        let points = PythonObject([])
        for i in range(tensor.shape()[1]):
            let x = tensor[Index(0, i)]
            let y = tensor[Index(1, i)]
            _ = points.append((x.cast[DType.float64](), y.cast[DType.float64]()))
        return shapely.MultiPoint(points)


    let multipoint_py = shapely_multipoint_from_tensor(tensor)
    let bounds_py = shapely.bounds(multipoint_py)
    test_envelope_eq_shapely_bounds[dtype, dims](env_result, bounds_py)


    fn shapely_bounds_worker() raises:
        _ = shapely.bounds(multipoint_py)
    shapely_bounds_worker()

    let envelope_shapely = benchmark.run[shapely_bounds_worker]()
 

fn test_envelope_eq_shapely_bounds[dtype: DType, dims: Int](envelope: SIMD[dtype, result_len], bounds: PythonObject) raises:
    for i in range(2 * dims):
        if not assert_true(envelope[i].cast[DType.float64]() == bounds[i].to_float64(), "invalid bounds"):
            raise Error("invalid bounds i: " + String(i))
