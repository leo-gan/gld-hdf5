from std.collections import List

from Series import Series


def fail(msg: String) raises:
    raise Error(msg)


def main() raises:
    var s = Series()
    s.values.append(1.5)
    s.values.append(-2.0)
    var raw = s.encode()
    var back = Series.decode_from(raw)
    if len(back.values) != 2 or back.values[0] != 1.5 or back.values[1] != -2.0:
        fail(String("generated"))
    print("ok")
