import numpy as np

from ..naive import envelope as envelope_naive
from ..optimized_numpy import envelope as envelope_numpy


def test_python_impls():
    """
    Test the python implementations are consistent.
    """
    multipoint_10_3 = np.array(np.random.rand(2, 10**3), dtype=np.float32)

    result_naive = envelope_naive(
        x_coords=list(multipoint_10_3[0]), y_coords=list(multipoint_10_3[1])
    )
    result_numpy = envelope_numpy(multipoint_10_3)
    assert result_naive == result_numpy
