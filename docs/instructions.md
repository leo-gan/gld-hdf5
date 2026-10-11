# Instructions

These steps assume a Linux x86-64 machine and Mojo 1.1.0. The package name on
prefix.dev is `mojo-hdf5`. The Mojo import is `hdf5`.

## Install from prefix.dev

```bash
pixi add --channel https://prefix.dev/leo-gan/leo-gan mojo-hdf5
```

The package depends on `mojo-compiler` 1.1. After it is installed, `from hdf5
import H5Doc, write_hdf5` works without an extra include path. The same
install provides `gld-hdf5gen-mojo`.

## Build this repository

```bash
git clone https://github.com/leo-gan/gld-hdf5.git
cd gld-hdf5
pixi install
pixi run test
```

`pixi.toml` pins `mojo == 1.1.0` and uses the Modular MAX channel plus
conda-forge, linux-64 only. If `pixi install` returns 401 from
`conda.modular.com`, export `PREFIX_API_KEY` and retry. A local `.env` file is
the place for that token. It is gitignored. Do not commit it.

| Task | What it runs |
| --- | --- |
| `pixi run test` | Every `tests/test_*.mojo` file. |
| `pixi run generate` | Writes `tests/generated` from `testdata/schema`. |
| `pixi run check-generated` | Regenerates into a temp directory and diffs. |
| `pixi run precompile` | Writes `/tmp/mojo-hdf5-pkg` and `gld-hdf5gen-mojo`. |
| `pixi run microbench` | Prints nanoseconds per encode and decode of a 4096-value dataset. Needs the `bench` feature: `pixi run -e bench microbench`. |
| `pixi run oracle` | Writes sample files and runs `h5dump`, `ncdump`, and `bpls` when they are on `PATH`. |

## Write a dataset

```mojo
from std.collections import List, Span

from hdf5 import H5Doc, read_hdf5, write_hdf5

fn main() raises:
    var doc = H5Doc()
    var root = doc.add_group(-1, String(""))
    var vals = List[Float64]()
    vals.append(1.0)
    _ = doc.add_f64(root, String("a"), vals, 0, 0)
    var raw = write_hdf5(doc)
    var back = read_hdf5(Span(raw))
    print(len(raw), back.d_n0[0])
```

`add_f64` arguments after the values are the chunk length and a gzip flag.
`0, 0` is contiguous and uncompressed. A positive chunk length selects chunked
layout. Gzip is stored-block deflate and is only valid with chunks.

Group 0 is the root. Its name is empty. Other groups use `add_group(parent, name)`.

## Generate a struct

```bash
pixi run mojo run -I src src/codegen/cli.mojo -- \
  --schema testdata/schema/series.json --out tests/generated
```

The schema is one JSON object with `name`, `dataset`, `dtype` (`float64`), and
`rank` (`1`). The struct's `encode` writes an HDF5 file. `decode_from` reads
it.
