import numpy as np

def envelope(arr: np.array) -> list[float]:
    """
    Calculate envelope with numpy, 'the fundamental package for scientific computing with Python'.
    """
    xmin = arr[0].min()
    xmax = arr[0].max()
    ymin = arr[1].min()
    ymax = arr[1].max()
    return [xmin, ymin, xmax, ymax]
