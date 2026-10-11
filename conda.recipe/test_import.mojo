from std.collections import List, Span

from hdf5 import DT_F64, H5Doc, VERSION, read_hdf5, write_hdf5


def main() raises:
    var doc = H5Doc()
    var root = doc.add_group(-1, String(""))
    var vals = List[Float64]()
    vals.append(1.0)
    _ = doc.add_f64(root, String("a"), vals, 0, 0)
    var raw = write_hdf5(doc)
    var back = read_hdf5(Span(raw))
    if len(back.d_name) != 1 or back.d_dtype[0] != DT_F64:
        raise Error("import round trip failed")
    print("hdf5 import ok", VERSION)
