# gld-hdf5 design

mojo-hdf5 is a from-scratch HDF5, NetCDF, and ADIOS2 BP5 library for Mojo
1.1.0. The runtime never calls an HDF5, NetCDF, or ADIOS2 library written in
another language. `h5dump`, `ncdump`, and `bpls` may be used as test oracles.
They are not build or run dependencies.

## Goals

The library writes files it can read back to the same numeric values, and
writes the subset of HDF5 and classic NetCDF that the oracles accept for the
cases below. It does not aim to read every file libhdf5 can open.

## HDF5

Files use **superblock version 0**. Offsets and lengths are 8 bytes. The root
group symbol-table entry is embedded in the superblock. Undefined addresses
are all `0xFF` bytes.

| Piece | Choice |
| --- | --- |
| Groups | Version-1 B-tree (`TREE`, node type 0) plus local heap (`HEAP`) and symbol-table nodes (`SNOD`). Leaf K is 4 (8 names per node). Internal K is 16. |
| Object headers | Version 1. Messages are 8-byte aligned. |
| Datatypes | Little-endian int8/16/32/64, uint8/16/32/64, float32, float64. Fixed-length null-terminated UTF-8 strings for attributes. |
| Dataspaces | Version 1. Scalar, 1-D, and 2-D. Current and maximum sizes are both stored. |
| Layout | Version 3. Contiguous, or chunked through a version-1 raw-data B-tree (indexed-storage K 32, the library default when the superblock does not store it). |
| Chunks | Full chunk shape, zero-filled past the array edge, including partial edge chunks. |
| Filter | Pipeline message, filter id 1 (`deflate`). The bytes are a zlib wrapper around deflate stored blocks (BTYPE 00). That is legal deflate. The reader inflates stored blocks only. |
| Attributes | Version 1, on groups and on datasets. Numeric scalars and UTF-8 strings. |

Link names in one group are limited to 256 (32 symbol nodes). Names are sorted
as unsigned bytes. The writer allocates objects in that sorted depth-first
order so a read followed by a write reproduces the same bytes.

`h5dump` 2.2.0 and h5py read a 1-D float64 file, a gzip-chunked float64 file,
groups, and attributes produced by this writer.

## NetCDF classic

`write_cdf1` emits **CDF-1** (`CDF\x01`). Integers in the header and float64
values are big-endian. Dimensions have positive lengths. There are no record
variables. Global and per-variable attributes are `NC_CHAR`. Variables are
float64, scalar or 1-D. `ncdump` prints this header and the values.

## NetCDF-4

`write_nc4` is an HDF5 file, not a second container. Each dimension is a 1-D
float64 dataset of the indices `0 .. length-1` with:

| Attribute | Value |
| --- | --- |
| `CLASS` | `DIMENSION_SCALE` |
| `NAME` | dimension name |
| `_Netcdf4Dimid` | int32 dimension index |
| `_netcdf_dim_info` | `name=<name>;length=<n>;unlimited=0` |

A variable dataset stores `_netcdf_dim_info` as `dims=<name>` plus the caller's
text attributes. The root group stores `_NCProperties` and global text
attributes. Unlimited dimensions and HDF5 variable-length `DIMENSION_LIST`
references are not written. `read_nc4` rebuilds the dimension and variable
lists from those attributes. On the sample file, `ncdump` also printed the
dimension, the variable, and the text attribute.

## ADIOS2 BP5

`write_bp5` creates a directory with `md.idx`, `md.0`, `mmd.0`, and `data.0`.
`data.0` is the raw little-endian float64 payload, which is the BP5 layout for
one uncompressed local block. The other three files are a small text record:

```
GLD-BP5
version 1
var <name>
count <n>
attr <name>
text <value>
```

`mmd.0` starts with `not-ffs` because this is **not** the FFS meta-metadata
ADIOS 2.10.2 writes. `bpls` 2.10.2 does not open the directory (`BP5Reader`
rejects the index). `read_bp5` does. The writer does not shell out to the
ADIOS2 C++ library. BP4 was not used: its characteristic index is a different
binary format, and the gap would still be "oracle metadata," while the BP5
data file for this case is the raw array we can write directly.

## Code generation

`gld-hdf5gen-mojo --schema FILE --out DIR` reads one JSON object:

```json
{"name":"Series","dataset":"values","dtype":"float64","rank":1}
```

It emits a Mojo struct with `encode` and `decode_from` that call the HDF5
writer and reader. Rank must be 1 and the dtype must be `float64`.

## What is not implemented

- Superblock versions other than 0, and object header version 2.
- Variable-length HDF5 strings, compounds, references, and filters other than
  stored-block deflate.
- Dynamic or fixed Huffman inflate. Files produced by libhdf5's default gzip
  level are not inflated here. Files this library writes are.
- NetCDF record variables and CDF-2/CDF-5.
- A `bpls`-compatible BP5 or BP4 metadata stream.
