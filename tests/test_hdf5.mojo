from std.collections import List, Span
from std.memory import bitcast

from runtime.bytes import append_f64, bytes_eq
from runtime.doc import DT_F32, DT_F64, DT_I16, DT_I32, DT_U8, H5Doc
from wire.hdf5 import read_hdf5, write_hdf5


def fail(msg: String) raises:
    raise Error(msg)


def pack_i32(v: Int) -> List[Byte]:
    var out = List[Byte]()
    var x = v
    var i = 0
    while i < 4:
        out.append(Byte(x & 255))
        x = x >> 8
        i += 1
    return out^


def pack_i16s(vals: List[Int]) -> List[Byte]:
    var out = List[Byte]()
    var i = 0
    while i < len(vals):
        var x = vals[i]
        out.append(Byte(x & 255))
        out.append(Byte((x >> 8) & 255))
        i += 1
    return out^


def as_f64(raw: List[Byte]) raises -> List[Float64]:
    var out = List[Float64]()
    var i = 0
    while i + 8 <= len(raw):
        var u = UInt64(0)
        var s = 7
        while s >= 0:
            u = (u << 8) | UInt64(Int(raw[i + s]))
            s -= 1
        out.append(bitcast[DType.float64](u))
        i += 8
    return out^


def find_ds(doc: H5Doc, name: String) -> Int:
    var i = 0
    while i < len(doc.d_name):
        if doc.d_name[i] == name:
            return i
        i += 1
    return -1


def main() raises:
    var doc = H5Doc()
    var root = doc.add_group(-1, String(""))
    var vals = List[Float64]()
    vals.append(1.0)
    vals.append(2.5)
    vals.append(-3.25)
    var a = doc.add_f64(root, String("a"), vals, 0, 0)
    var g = doc.add_group(root, String("g"))
    doc.add_num_attr_group(g, String("n"), DT_I32, pack_i32(7))
    doc.add_text_attr_group(g, String("note"), String("hi"))
    var matrix = List[Byte]()
    var m = 1
    while m <= 4:
        var row = pack_i32(m)
        var b = 0
        while b < len(row):
            matrix.append(row[b])
            b += 1
        m += 1
    var mid = doc.add_dataset(g, String("m"), DT_I32, 2, 2, 2, matrix^, 0, 0, 0, 0)
    doc.add_text_attr_dataset(mid, String("u"), String("ok"))
    var scalar = List[Byte]()
    var fbits = Int(bitcast[DType.uint32](Float32(1.5)))
    var sft = 0
    while sft < 4:
        scalar.append(Byte((fbits >> (sft * 8)) & 255))
        sft += 1
    _ = doc.add_dataset(root, String("s"), DT_F32, 0, 0, 0, scalar^, 0, 0, 0, 0)
    var series = List[Float64]()
    var n = 0
    while n < 8:
        series.append(Float64(n))
        n += 1
    _ = doc.add_f64(root, String("c"), series, 4, 1)
    var partial = List[Byte]()
    partial.append(Byte(0))
    partial.append(Byte(1))
    partial.append(Byte(2))
    partial.append(Byte(3))
    partial.append(Byte(4))
    _ = doc.add_dataset(root, String("u8"), DT_U8, 1, 5, 0, partial^, 1, 3, 0, 0)
    var grid = List[Int]()
    var gv = 1
    while gv <= 15:
        grid.append(gv)
        gv += 1
    _ = doc.add_dataset(root, String("p"), DT_I16, 2, 3, 5, pack_i16s(grid^), 1, 2, 2, 0)
    _ = a
    var raw = write_hdf5(doc)
    if len(raw) < 96 or Int(raw[0]) != 0x89 or Int(raw[8]) != 0:
        fail(String("superblock version 0"))
    var back = read_hdf5(Span(raw))
    var again = write_hdf5(back)
    if not bytes_eq(raw, again):
        fail(String("rewrite"))
    var ai = find_ds(back, String("a"))
    var got = as_f64(back.d_data[ai])
    if len(got) != 3 or got[0] != 1.0 or got[1] != 2.5 or got[2] != Float64(-3.25):
        fail(String("f64 values"))
    var ci = find_ds(back, String("c"))
    if back.d_gzip[ci] != 1 or back.d_chunked[ci] != 1:
        fail(String("gzip flags"))
    var cg = as_f64(back.d_data[ci])
    if len(cg) != 8 or cg[7] != 7.0:
        fail(String("gzip values"))
    var ui = find_ds(back, String("u8"))
    if len(back.d_data[ui]) != 5 or Int(back.d_data[ui][4]) != 4:
        fail(String("partial chunk"))
    var pi = find_ds(back, String("p"))
    if len(back.d_data[pi]) != 30:
        fail(String("2d chunk length"))
    if Int(back.d_data[pi][18]) != 10 or Int(back.d_data[pi][19]) != 0:
        fail(String("2d partial value 10"))
    if Int(back.d_data[pi][28]) != 15 or Int(back.d_data[pi][29]) != 0:
        fail(String("2d last value"))
    var si = find_ds(back, String("s"))
    if back.d_rank[si] != 0 or len(back.d_data[si]) != 4:
        fail(String("scalar"))
    var note = 0
    var attr = 0
    while attr < len(back.a_name):
        if back.a_name[attr] == String("note") and back.a_text[attr] == String("hi"):
            note = 1
        if back.a_name[attr] == String("u") and back.a_text[attr] == String("ok"):
            note += 1
        attr += 1
    if note != 2:
        fail(String("attributes"))
    var gi = 0
    var saw = 0
    while gi < len(back.g_name):
        if back.g_name[gi] == String("g"):
            saw = 1
        gi += 1
    if saw != 1:
        fail(String("group"))
    print("ok")
