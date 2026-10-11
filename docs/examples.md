# Examples

## HDF5 dataset

`examples/encode_dataset.mojo` builds a 1-D float64 dataset, attaches a text
attribute, and reads the values back.

```bash
pixi run mojo run -I src examples/encode_dataset.mojo
```

Chunked gzip uses the same call with a chunk length and gzip flag of 1:

```mojo
_ = doc.add_f64(root, String("c"), vals, 4, 1)
```

A 2-D array is `add_f64_2d`. Other integer widths go through `add_dataset`
with a dtype constant such as `DT_I32` and little-endian bytes.

## Classic NetCDF

```mojo
from hdf5 import DT_F64, NcFile, write_cdf1, read_cdf1

fn main() raises:
    var nc = NcFile()
    var dim = nc.add_dim(String("n"), 3)
    var vals = List[Float64]()
    vals.append(1.0)
    vals.append(2.5)
    vals.append(-3.25)
    var v = nc.add_var(String("v"), DT_F64, dim, vals)
    nc.add_attr(-1, String("title"), String("hello"))
    nc.add_attr(v, String("units"), String("m"))
    var raw = write_cdf1(nc)
    var back = read_cdf1(Span(raw))
    print(back.var_data[0][1])
```

`write_nc4` writes the same document as HDF5 with dimension-scale attributes
and `_netcdf_dim_info`.

## One BP5 step

```mojo
from hdf5 import BpStep, read_bp5, write_bp5

fn main() raises:
    var step = BpStep()
    step.var_name = String("v")
    step.values.append(1.0)
    step.attr_name = String("note")
    step.attr_text = String("hi")
    write_bp5(String("step.bp"), step)
    var back = read_bp5(String("step.bp"))
    print(back.attr_text)
```

## Generated struct

```mojo
from Series import Series

fn main() raises:
    var s = Series()
    s.values.append(1.5)
    var raw = s.encode()
    var back = Series.decode_from(raw)
    print(back.values[0])
```

Compile that with `-I src -I tests/generated` from a checkout, or with the
precompiled package on the include path.
