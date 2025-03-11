# Spatial envelope optimization and benchmarks

A [Mojo]((https://docs.modular.com/mojo/manual)🔥 project created for the [ModCon23
contest](https://www.modular.com/mojo). It was
[Finalist #6](https://www.modular.com/newsletters/modverse-weekly-issue-11).

Calculates the spatial envelope, and explores the performance of Python, NumPy,
and Mojo. *The Mojo final implementation is 20X to 600X faster than Python,
and 1.3X to 4X faster than [NumPy](https://numpy.org/).*

## Envelope

Calculating an envelope is a fundamental part of spatial analysis. The envelope
(aka: bounds, bbox, mbr) is usually defined by an xmin, ymin, xmax, and ymax
representing the minimum and maximum x (longitude) and y (latitude) coordinates
that encompass the bounded feature(s).

![bounding box](./docs/img/bounding_box.png)

Figure attribution: [QGIS documentation](https://docs.qgis.org): Fig. 27.53 Black lines represent the bounding boxes of each polygon feature.

## Variants benchmarked

- [naïve Python](./py_impl/naive.py)
- [naïve Mojo](./mojo_impl/naive.mojo)
- [Python using NumPy (well-optimized C code)](./py_impl/optimized_numpy.py)
- [Mojo optimized with vectorization and loop unrolling, single-threaded (mojo optimized "a")](./mojo_impl/optimized_a.mojo)
- [Mojo optimized with parallelization, vectorization and loop unrolling. (mojo optimized "b")](./mojo_impl/optimized_b.mojo)

## Variants also considered

The [Shapely](https://shapely.readthedocs.io/en/stable/) package wraps the
[GEOS library](https://libgeos.org/), another well-optimized C/C++ codebase.
Shapely caches the envelope upon geometry creation, so it was not feasible to
benchmark the envelope calculations separately from geometry constructors. For
that reason, Shapely was not included in the benchmarks.

## All benchmarks

Test system: mojo `0.5.0` on Apple M2, 24GB RAM. Data type: `float32`.

![overall benchmarks](./docs/img/benchmarks-1.png)
[raw results spreadsheet](./docs/benchmark-results.ods)

## Chart of optimized variants only

![optimized benchmarks](./docs/img/benchmarks-2.png)

## Key Findings

1. [Mojo optimized "a"](./mojo_impl/optimized_a.mojo) is the best overall
performer. However for large feature spaces (millions of points) we can get
at least an additional 25% speedup by using one thread per dimension, as shown in
[Mojo optimized "b"](./mojo_impl/optimized_b.mojo).

2. Even more performance optimizations are possibly left on the table, such as
auto-tuning, stack allocation, and tiled/striped memory access. A fusion of
Mojo optimized "a" and "b" could offer the best performance across all feature
sizes.

3. In addition to being performance winners, the Mojo variants are
parameterized by the number of dimensions (`dims`) and by data type (`dtype`).
In other words, the same generic code can run, for example, `int16`, `float16`,
`float64`, and with 3, 4 or more dimensions. In GIS systems the number of
dimensions is sometimes referred to as XY, XYZ, or XYZM, where Z is "height",
and M is "measure".

## Example output including Mojo's `benchmark` report

```text
$ mojo mojo_impl/optimized_a.mojo 100
float32 100
---------------------
Benchmark Report (s)
---------------------
Mean: 6.5356175103213615e-07
Total: 0.75083200000000005
Iters: 1148831
Warmup Mean: 9.9999999999999995e-07
Warmup Total: 1.9999999999999999e-06
Warmup Iters: 2
Fastest Mean: 6.4460000000000004e-07
Slowest Mean: 7.9999999999999996e-07

ns: 653.56175103213616
microsecs: 0.6535617510321361
ms: 0.0006535617510321361
s: 6.5356175103213615e-07
```

