# Test data

Records live under `testdata/`. They are inputs to the code generator and notes
for the oracle commands. The unit tests build their arrays in memory. They do
not load a binary file from disk.

## Schema

`testdata/schema/series.json` is the code-generation input:

```json
{"name":"Series","dataset":"values","dtype":"float64","rank":1}
```

`pixi run generate` writes `tests/generated/Series.mojo`. `pixi run
check-generated` diffs a fresh run against that file. `tests/test_generated.mojo`
encodes two float64 values and decodes them.

## What the unit tests cover

| Test | What it checks |
| --- | --- |
| `tests/test_hdf5.mojo` | Superblock version byte 0. Scalar float32, 1-D float64, 2-D int32, chunked gzip float64, partial uint8 chunks, partial 2-D int16 chunks, group and dataset attributes. A second write matches the first file's bytes. |
| `tests/test_netcdf.mojo` | CDF-1 magic and a round trip of one dimension, one float64 variable, a global text attribute, and a variable text attribute. The same document through NetCDF-4. |
| `tests/test_bp5.mojo` | One BP5 directory: variable `v`, values `1`, `2.5`, `-3.25`, attribute `note=hi`. |
| `tests/test_deflate.mojo` | Adler-32 of an empty buffer, a stored-block round trip, and a multi-block buffer larger than 65535 bytes. |

## Oracles

`scripts/oracle.sh` writes `/tmp/gld-hdf5-oracle-f64.h5`,
`/tmp/gld-hdf5-oracle-classic.nc`, `/tmp/gld-hdf5-oracle-nc4.h5`, and
`/tmp/gld-hdf5-oracle-step.bp`. When the tools are installed:

- `h5dump` prints the float64 dataset `1, 2.5, -3.25`.
- `ncdump` prints the classic file, and `ncdump -k` reports `classic`.
- `bpls` does not open the BP5 directory. The script does not treat that as a
  crash of the library. The gap is documented in Techniques.

These tools are not installed in the GitHub Actions job. The job runs
`pixi run test`, which does not need them.
