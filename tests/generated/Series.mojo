from std.collections import List, Span
from std.memory import bitcast

from hdf5 import DT_F64, H5Doc, read_hdf5, write_hdf5


struct Series(Movable):
    var values: List[Float64]

    def __init__(out self):
        self.values = List[Float64]()

    def encode(self) raises -> List[Byte]:
        var doc = H5Doc()
        var root = doc.add_group(-1, String(""))
        _ = doc.add_f64(root, String("values"), self.values, 0, 0)
        return write_hdf5(doc)

    @staticmethod
    def decode_from(raw: List[Byte]) raises -> Series:
        var doc = read_hdf5(Span(raw))
        var out = Series()
        var i = 0
        while i < len(doc.d_name):
            if doc.d_name[i] == String("values") and doc.d_dtype[i] == DT_F64:
                var k = 0
                while k + 8 <= len(doc.d_data[i]):
                    var bits = UInt64(0)
                    var s = 7
                    while s >= 0:
                        bits = (bits << 8) | UInt64(Int(doc.d_data[i][k + s]))
                        s -= 1
                    out.values.append(bitcast[DType.float64](bits))
                    k += 8
                return out^
            i += 1
        raise Error("generated dataset was not found")
