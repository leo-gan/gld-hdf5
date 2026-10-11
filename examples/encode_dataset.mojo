from std.collections import List, Span

from hdf5 import H5Doc, read_hdf5, write_hdf5


def main() raises:
    var doc = H5Doc()
    var root = doc.add_group(-1, String(""))
    var vals = List[Float64]()
    vals.append(1.0)
    vals.append(2.5)
    vals.append(-3.25)
    _ = doc.add_f64(root, String("a"), vals, 0, 0)
    doc.add_text_attr_dataset(0, String("units"), String("m"))
    var raw = write_hdf5(doc)
    var back = read_hdf5(Span(raw))
    print("bytes", len(raw))
    print("dataset", back.d_name[0], "count", back.d_n0[0])
    print("attr", back.a_name[0], back.a_text[0])
