from random import rand
from sys import argv
from tensor import Tensor, TensorSpec
from math.limit import inf, neginf

from mojo_impl.tests.util import MojoTest
from mojo_impl.naive import envelope as envelope_naive
from mojo_impl.optimized_a import envelope as envelope_opt_a
from mojo_impl.optimized_b import envelope as envelope_opt_b


fn main() raises:
    test_mojo_impls_int16()
    test_mojo_impls_float32()
    test_mojo_impls_float64()


fn test_mojo_impls_int16():
    alias dtype = DType.int16
    alias dims = 2
    alias width = 1000

    let test = MojoTest("mojo implementations are all consistent: " + dtype.__str__())

    # create a tensor, filled with random values
    let spec = TensorSpec(dtype, dims, width)
    let tensor = rand[dtype](spec)

    # check the 3 mojo implementations all return the same value
    let result_naive = envelope_naive[dtype, dims](tensor)

    let result_opt_a = envelope_opt_a[dtype, dims](tensor)
    test.assert_true(result_naive == result_opt_a, "naive == envelope_opt_a")

    let result_opt_b = envelope_opt_b[dtype, dims](tensor)
    test.assert_true(result_naive == result_opt_b, "naive == envelope_opt_b")


fn test_mojo_impls_float64():
    alias dtype = DType.float64
    alias dims = 4
    alias width = 1000

    let test = MojoTest("mojo implementations are all consistent: " + dtype.__str__())

    # create a tensor, filled with random values
    let spec = TensorSpec(dtype, dims, width)
    let tensor = rand[dtype](spec)

    # check the 3 mojo implementations all return the same value
    let result_naive = envelope_naive[dtype, dims](tensor)

    let result_opt_a = envelope_opt_a[dtype, dims](tensor)
    test.assert_true(result_naive == result_opt_a, "naive == envelope_opt_a")

    let result_opt_b = envelope_opt_b[dtype, dims](tensor)
    test.assert_true(result_naive == result_opt_b, "naive == envelope_opt_b")


fn test_mojo_impls_float32():
    alias dtype = DType.float32
    alias dims = 8
    alias width = 1000

    let test = MojoTest("mojo implementations are all consistent: " + dtype.__str__())

    # create a tensor, filled with random values
    let spec = TensorSpec(dtype, dims, width)
    let tensor = rand[dtype](spec)

    # check the 3 mojo implementations all return the same value
    let result_naive = envelope_naive[dtype, dims](tensor)

    let result_opt_a = envelope_opt_a[dtype, dims](tensor)
    test.assert_true(result_naive == result_opt_a, "naive == envelope_opt_a")

    let result_opt_b = envelope_opt_b[dtype, dims](tensor)
    test.assert_true(result_naive == result_opt_b, "naive == envelope_opt_b")
