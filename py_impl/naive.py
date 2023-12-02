from math import inf


def envelope(x_coords: list[float], y_coords: list[float]) -> list[float]:
    """
    Calculate envelope with iterative, plain python code.
    """
    assert len(x_coords) == len(y_coords)

    result: list[float] = [inf, inf, -inf, -inf]

    for i in range(len(x_coords)):
        x = x_coords[i]
        y = y_coords[i]

        if x < result[0]:
            result[0] = x
        if y < result[1]:
            result[1] = y

        if x > result[2]:
            result[2] = x
        if y > result[3]:
            result[3] = y

    return result
