from runtime.doc import BpStep
from wire.bp5 import read_bp5, write_bp5


def fail(msg: String) raises:
    raise Error(msg)


def main() raises:
    var step = BpStep()
    step.var_name = String("v")
    step.values.append(1.0)
    step.values.append(2.5)
    step.values.append(Float64(-3.25))
    step.attr_name = String("note")
    step.attr_text = String("hi")
    var path = String("/tmp/gld-hdf5-bp5-test.bp")
    write_bp5(path, step)
    var back = read_bp5(path)
    if back.var_name != String("v") or back.attr_name != String("note") or back.attr_text != String("hi"):
        fail(String("meta"))
    if len(back.values) != 3 or back.values[0] != 1.0 or back.values[1] != 2.5 or back.values[2] != Float64(-3.25):
        fail(String("values"))
    print("ok")
