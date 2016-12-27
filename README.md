# RTLSDR

A wrapper for the librtlsdr libraries. Currently, this only works on linux (I think). You need to download the librtlsdr libraries. In the future, I will discuss how to do this.

This code is heavily based off the [pyrtlsdr libary](https://github.com/roger-/pyrtlsdr) by github user `roger-`.

## Example
DOCUMENTATION NEEDS A LOT OF WORK
```
using RTLSDR

r = RtlSdr()		# creates a RtlSdr object with a dongle pointer

set_rate(r, 2.0e6)
get_rate(r)

set_freq(r, 88.5e6)		# if we wanted the center freq on NPR
get_rate(r)

close(r)
```

[![Build Status](https://travis-ci.org/dressel/RTLSDR.jl.svg?branch=master)](https://travis-ci.org/dressel/RTLSDR.jl)

[![Coverage Status](https://coveralls.io/repos/dressel/RTLSDR.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/dressel/RTLSDR.jl?branch=master)

[![codecov.io](http://codecov.io/github/dressel/RTLSDR.jl/coverage.svg?branch=master)](http://codecov.io/github/dressel/RTLSDR.jl?branch=master)
