# Techniques

## Superblock version 0

The file starts with the 8-byte signature `89 48 44 46 0d 0a 1a 0a`. Byte 8
is the superblock version. This writer stores 0. Bytes 13 and 14 are the
offset size and the length size, both 8. The root group's object-header
address and its B-tree and heap addresses sit in the symbol-table entry at
the end of the 96-byte superblock. The end-of-file address is the file length.

Groups then use a version-1 B-tree whose keys are offsets into a local heap of
null-terminated names. Each leaf points at a symbol-table node of up to eight
entries. A link stores the child object-header address. Dataset object headers
carry a dataspace, a datatype, a fill-value message, an optional deflate
pipeline, and a version-3 layout message.

Contiguous layout stores one address and one byte length. Chunked layout
stores the chunk shape as 4-byte sizes (the element size is an extra
dimension) and the address of a raw-data B-tree. Chunk keys hold the stored
size, a filter mask, and the chunk origin. The node is sized for K = 32
because version 0 does not record the indexed-storage K, and libhdf5's default
is 32.

## Deflate

HDF5 filter id 1 is zlib, not a gzip wrapper. The compressor here emits a zlib
header `78 01`, then one or more deflate stored blocks, then an Adler-32.
Stored blocks are uncompressed but they are valid deflate, so `h5dump` and
h5py inflate them. The reader checks the zlib header, copies stored blocks,
and verifies Adler-32. It does not implement fixed or dynamic Huffman codes,
so a typical libhdf5 gzip chunk will not round-trip through this reader.

Partial edge chunks are stored as a full chunk of zeros with the in-range
elements filled in, which is what libhdf5 does for unfiltered chunks and for
the input of the deflate filter.

## NetCDF

CDF-1 packs names as a big-endian length, the bytes, and padding to 4. The
variable's `begin` field is the absolute offset of its big-endian float64
payload. CDF-2 (64-bit offsets) and record variables are not written.

NetCDF-4 reuses the HDF5 writer. `_netcdf_dim_info` is a UTF-8 attribute.
On a dimension it is `name=<name>;length=<n>;unlimited=0`. On a variable it is
`dims=<name>`. `CLASS=DIMENSION_SCALE` marks the dimension dataset.

## BP5

A BP5 dataset is a directory. This writer creates `data.0` as packed
little-endian float64 values and writes `md.idx`, `md.0`, and `mmd.0` as the
text record described in [DESIGN.md](https://github.com/leo-gan/gld-hdf5/blob/main/DESIGN.md).
ADIOS 2.10.2 expects FFS in those metadata files. `bpls` reports that it
cannot open the directory. The Mojo reader parses the text record and the
payload. Nothing in the writer calls the ADIOS2 C++ API.

## Code generation

The generator does not parse a general JSON grammar. It finds the four keys
`name`, `dataset`, `dtype`, and `rank`. The emitted struct keeps a
`List[Float64]` and calls `write_hdf5` / `read_hdf5`.
