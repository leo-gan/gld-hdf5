from std.collections import List, Span

from runtime.doc import DT_F64, BpStep, H5Doc, NcFile
from wire.bp5 import write_bp5
from wire.hdf5 import write_hdf5
from wire.netcdf import write_cdf1, write_nc4


def main() raises:
    var doc = H5Doc()
    var root = doc.add_group(-1, String(""))
    var vals = List[Float64]()
    vals.append(1.0)
    vals.append(2.5)
    vals.append(-3.25)
    _ = doc.add_f64(root, String("a"), vals, 0, 0)
    var raw = write_hdf5(doc)
    var handle = open("/tmp/gld-hdf5-oracle-f64.h5", "w")
    handle.write_bytes(Span(raw))
    handle.close()

    var nc = NcFile()
    var dim = nc.add_dim(String("n"), 3)
    var data = List[Float64]()
    data.append(1.0)
    data.append(2.5)
    data.append(-3.25)
    var vi = nc.add_var(String("v"), DT_F64, dim, data)
    nc.add_attr(-1, String("title"), String("hello"))
    nc.add_attr(vi, String("units"), String("m"))
    var classic = write_cdf1(nc)
    var cf = open("/tmp/gld-hdf5-oracle-classic.nc", "w")
    cf.write_bytes(Span(classic))
    cf.close()
    var nc4 = write_nc4(nc)
    var nf = open("/tmp/gld-hdf5-oracle-nc4.h5", "w")
    nf.write_bytes(Span(nc4))
    nf.close()

    var step = BpStep()
    step.var_name = String("v")
    step.values.append(1.0)
    step.values.append(2.5)
    step.values.append(-3.25)
    step.attr_name = String("note")
    step.attr_text = String("hi")
    write_bp5(String("/tmp/gld-hdf5-oracle-step.bp"), step)
    print("wrote oracle files")
