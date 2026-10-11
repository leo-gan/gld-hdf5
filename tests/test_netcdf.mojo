from std.collections import List, Span

from runtime.doc import DT_F64, NcFile
from wire.netcdf import read_cdf1, read_nc4, write_cdf1, write_nc4


def fail(msg: String) raises:
    raise Error(msg)


def sample() -> NcFile:
    var nc = NcFile()
    var dim = nc.add_dim(String("n"), 3)
    var vals = List[Float64]()
    vals.append(1.0)
    vals.append(2.5)
    vals.append(-3.25)
    var var_i = nc.add_var(String("v"), DT_F64, dim, vals^)
    nc.add_attr(-1, String("title"), String("hello"))
    nc.add_attr(var_i, String("units"), String("m"))
    return nc^


def check(nc: NcFile) raises:
    if len(nc.dim_name) != 1 or nc.dim_name[0] != String("n") or nc.dim_len[0] != 3:
        fail(String("dim"))
    if len(nc.var_name) != 1 or nc.var_name[0] != String("v"):
        fail(String("var"))
    if len(nc.var_data[0]) != 3 or nc.var_data[0][1] != 2.5 or nc.var_data[0][2] != Float64(-3.25):
        fail(String("values"))
    var title = 0
    var units = 0
    var i = 0
    while i < len(nc.attr_name):
        if nc.attr_name[i] == String("title") and nc.attr_text[i] == String("hello") and nc.attr_var[i] < 0:
            title = 1
        if nc.attr_name[i] == String("units") and nc.attr_text[i] == String("m"):
            units = 1
        i += 1
    if title != 1 or units != 1:
        fail(String("attrs"))


def main() raises:
    var nc = sample()
    var classic = write_cdf1(nc)
    if len(classic) < 4 or Int(classic[0]) != 67 or Int(classic[3]) != 1:
        fail(String("magic"))
    check(read_cdf1(Span(classic)))
    var nc4 = write_nc4(nc)
    var back = read_nc4(Span(nc4))
    check(back)
    print("ok")
