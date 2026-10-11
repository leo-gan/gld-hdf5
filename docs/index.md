# mojo-hdf5

mojo-hdf5 is an HDF5, NetCDF, and ADIOS2 BP5 library written in
[Mojo](https://www.modular.com/mojo). The runtime and the code generator are
Mojo. They do not wrap libhdf5, libnetcdf, or libadios2.

<div class="grid cards" markdown="1">

-   __Why HDF5__

    ---

    What a group, a dataset, and a dataspace are, and how NetCDF and BP5 sit
    on top of the same idea.

    [:octicons-arrow-right-24: Read Why HDF5](why-hdf5.md)

-   __Instructions__

    ---

    Install Mojo 1.1.0 with pixi, write a dataset, generate a struct, and run
    the tests.

    [:octicons-arrow-right-24: Open Instructions](instructions.md)

-   __Examples__

    ---

    Encode a float64 dataset, a classic NetCDF file, and one BP5 step.

    [:octicons-arrow-right-24: See Examples](examples.md)

-   __Techniques__

    ---

    Superblock version 0, chunked layout, stored-block deflate, and the BP5
    metadata gap.

    [:octicons-arrow-right-24: Read Techniques](techniques.md)

-   __Test data__

    ---

    The records under `testdata/` and what the oracles are asked to read.

    [:octicons-arrow-right-24: Open Test data](test-data.md)

</div>
