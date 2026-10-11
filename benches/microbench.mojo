from std.collections import List, Span
from std.time import perf_counter_ns

from runtime.doc import H5Doc
from wire.hdf5 import read_hdf5, write_hdf5


def _sample() -> H5Doc:
    var doc = H5Doc()
    var root = doc.add_group(-1, String(""))
    var vals = List[Float64]()
    var i = 0
    while i < 4096:
        vals.append(Float64(i) * 0.5)
        i += 1
    _ = doc.add_f64(root, String("values"), vals, 0, 0)
    return doc^


def main() raises:
    var doc = _sample()
    var n = 50
    var i = 0
    while i < 5:
        _ = write_hdf5(doc)
        i += 1
    var t0 = perf_counter_ns()
    i = 0
    var enc_acc = 0
    while i < n:
        var raw_i = write_hdf5(doc)
        enc_acc += len(raw_i) + Int(raw_i[100])
        i += 1
    var enc = Int(perf_counter_ns() - t0) // n
    var raw = write_hdf5(doc)
    i = 0
    while i < 5:
        var warm = read_hdf5(Span(raw))
        enc_acc += len(warm.d_data[0])
        i += 1
    t0 = perf_counter_ns()
    i = 0
    var dec_acc = 0
    while i < n:
        var back = read_hdf5(Span(raw))
        dec_acc += len(back.d_data[0]) + Int(back.d_data[0][100])
        i += 1
    var dec = Int(perf_counter_ns() - t0) // n
    print("encode_ns", enc)
    print("decode_ns", dec)
    print("bytes", len(raw))
    print("checksum", enc_acc + dec_acc)
