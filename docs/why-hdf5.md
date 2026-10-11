# Why HDF5

Scientific codes need one file that holds many named arrays, the shape of each
array, and a few labels such as units. HDF5 is that container. A **group** is
a directory. A **dataset** is an array with a type and a shape. An
**attribute** is a small value attached to a group or a dataset. The bytes on
disk are a superblock, object headers, and the raw numbers.

This library writes **superblock version 0**. That is the original HDF5
superblock: an 8-byte signature, sizes of offsets and lengths, and the root
group's symbol-table entry. Version 0 is what current `h5dump` still reads,
and it avoids the checksummed version 2 superblock.

NetCDF classic is an older, smaller version of the same idea: a list of
dimensions, variables, and text attributes in one header. CDF-1 stores that
header in big-endian and the numbers after it. NetCDF-4 keeps the NetCDF
model but stores it as HDF5, using dimension-scale attributes so a dataset can
name the dimension it uses. This library writes both. Classic files are the
ones `ncdump` is required to print. The NetCDF-4 files follow the dimension
scale and `_netcdf_dim_info` conventions and are read back here.

ADIOS2 BP5 is a directory, not a single header. The array payload can be a
raw block. The metadata that `bpls` understands is FFS, a separate schema
encoding. This library writes the directory and the raw payload, and a
metadata record it can read itself. It does not claim that `bpls` accepts
that record.

The implementation is Mojo. It does not link the C libraries. Those tools are
only used, when they are installed, to check a file after it has been written.
