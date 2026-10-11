# mojo-hdf5

A from-scratch HDF5, NetCDF, and ADIOS2 BP5 library for [Mojo](https://www.modular.com/mojo).
The runtime and the code generator are written in Mojo. They do not wrap, link,
or vendor libhdf5, libnetcdf, libadios2, or any other C, C++, or Rust
implementation of those formats.

`h5dump`, `ncdump`, and `bpls` are **test oracles** only. They are not required
to encode or decode at runtime.

This repository is a standalone library. It is not part of any other project.

Documentation: [Why HDF5](https://leo-gan.github.io/gld-hdf5/why-hdf5/),
[Instructions](https://leo-gan.github.io/gld-hdf5/instructions/),
[Examples](https://leo-gan.github.io/gld-hdf5/examples/),
[Techniques](https://leo-gan.github.io/gld-hdf5/techniques/),
[Test data](https://leo-gan.github.io/gld-hdf5/test-data/).

## Install

Published package (linux-64) on [prefix.dev/leo-gan/leo-gan](https://prefix.dev/leo-gan/leo-gan):

```bash
pixi add --channel https://prefix.dev/leo-gan/leo-gan mojo-hdf5
```

That installs `hdf5.mojoc` (plus `wire`, `runtime`, and `schema`) and the
`gld-hdf5gen-mojo` CLI. It needs `mojo-compiler` 1.1. After install,
`from hdf5 import …` resolves with no extra `-I`.

From a git checkout (development):

```bash
git clone https://github.com/leo-gan/gld-hdf5.git
cd gld-hdf5
pixi install
pixi run test
```

Local precompile (no conda install):

```bash
pixi run precompile
```

`from hdf5 import …` then resolves from `/tmp/mojo-hdf5-pkg`
(`mojo run -I /tmp/mojo-hdf5-pkg …`).

The recipe is `conda.recipe/recipe.yaml`. A GitHub Release on this repo builds
it and uploads it to the channel above.

## What it reads and writes

| Surface | Behavior |
| --- | --- |
| HDF5 superblock version 0 | Groups, numeric datasets (scalar, 1-D, 2-D), contiguous and chunked layout, gzip/deflate stored blocks, numeric and UTF-8 attributes. |
| NetCDF classic | CDF-1 file with dimensions, a float64 variable, and text attributes. `ncdump` accepts the header. |
| NetCDF-4 | HDF5 file with dimension-scale attributes and `_netcdf_dim_info`. This library reads it back. |
| ADIOS2 BP5 | One step: a 1-D float64 variable and one string attribute. Metadata is not FFS, so `bpls` does not open it. The Mojo reader does. |

Numeric dataset values are little-endian. A file written here round-trips to
the same values. The writer is deterministic for a given document.

## Layout

`src/hdf5` is the public package. `src/runtime` holds the document model,
byte buffer, and deflate. `src/wire` holds the HDF5, NetCDF, and BP5 codecs.
`src/schema` and `src/codegen` turn a small JSON description into a Mojo struct.

Requires **Mojo 1.1.0**.
