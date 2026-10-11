from std.collections import List, Span

from runtime.bytes import append_f64, bytes_eq, load_f64
from runtime.deflate import adler32, zlib_inflate, zlib_store


def fail(msg: String) raises:
    raise Error(msg)


def main() raises:
    var empty = List[Byte]()
    if adler32(Span(empty)) != 1:
        fail(String("adler empty"))
    var hello = List[Byte]()
    var text = String("hello").as_bytes()
    var i = 0
    while i < len(text):
        hello.append(text[i])
        i += 1
    var z = zlib_store(Span(hello))
    var back = zlib_inflate(Span(z))
    if not bytes_eq(hello, back):
        fail(String("store round trip"))
    var big = List[Byte]()
    i = 0
    while i < 70000:
        big.append(Byte(i & 255))
        i += 1
    var z2 = zlib_store(Span(big))
    var back2 = zlib_inflate(Span(z2))
    if not bytes_eq(big, back2):
        fail(String("multi block"))
    var nums = List[Byte]()
    append_f64(nums, Float64(-3.25))
    if load_f64(Span(nums), 0) != Float64(-3.25):
        fail(String("f64 bits"))
    print("ok")
