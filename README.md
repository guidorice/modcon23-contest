# Spatial envelope optimization and benchmarks

A [Mojo](https://github.com/modularml/mojo)🔥 project calculating the spatial envelope, and exploring the
performance of Python, Numpy, and Mojo.

## Envelope

Calculating an envelope is a fundamental part of spatial analysis. The envelope
(aka: bounds, bbox, mbr) is usually defined by an xmin, ymin, xmax, and ymax
representing the minimum and maximum x (longitude) and y (latitude) coordinates
that encompass the bounded feature(s).


![bounding box](./docs/img/bounding_box.png)

[QGIS documentation](https://docs.qgis.org/3.28/en/docs/user_manual/processing_algs/qgis/vectorgeometry.html#bounding-boxes): Fig. 27.53 Black lines represent the bounding boxes of each polygon feature.

## Variants benchmarked

- naïve Python
- naïve Mojo
- [NumPy](https://numpy.org/) optimized Python
- Mojo optimized with vectorization and loop unrolling, single-threaded (mojo optimized "a")
- Mojo optimized with parallelization, vectorization and loop unrolling. (mojo optimized "b")

## All benchmarks

Test system: mojo 0.5.0 on Apple M2, 24GB RAM

![overall benchmarks](./docs/img/benchmarks-1.png)

## Optimized variants only

![optimized benchmarks](./docs/img/benchmarks-2.png)

## Key Findings

[Mojo optimized "a"](./mojo_impl/optimized_a.mojo) is the best overall
performer, but for large feature spaces (millions of points), adding an one
thread per dimension, can provide about a 25% speedup as shown in [Mojo
optimized "b"](./mojo_impl/optimized_b.mojo).
