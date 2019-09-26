# RTLSDR

A wrapper for the librtlsdr C libraries.
Currently, this only works on Linux (I think).
You need to download the librtlsdr libraries.

This code is heavily based off the
[pyrtlsdr libary](https://github.com/roger-/pyrtlsdr) by github user `roger-`.


## librtlsdr C libraries

Julia needs to find `librtlsdr.so` somewhere on your system.
To see if Julia can find it, you can use `find_library`:

```julia
using Libdl
find_library("librtlsdr")   # returns empty string if library not found
```

You can also type the following into an Ubuntu shell to help find it:

```shell
ldconfig -p | grep librtlsdr
```


## Quick Example

```julia
using RTLSDR

r = RtlSdr()

set_rate(r, 2.0e6)
set_freq(r, 88.5e6)		# if we wanted the center freq on NPR

samples = read_samples(r, 1024)

# plot power spectral density
using PyPlot
psd(samples)
```

## Function list
```julia
r = RtlSdr()            # creates RtlSdr object with dongle pointer

set_rate(r, rate_Hz)      # rtlsdr_set_sample_rate
get_rate(r)

set_freq(r, freq_Hz)    # rtlsdr_set_center_freq
get_freq(r)

set_agc_mode(r, mode)               # rtlsdr_set_agc_mode
set_tuner_gain_mode(r, manual)      # rtlsdr_set_tuner_gain_mode

close(r)    # rtlsdr_close. cannot read from r once this is called

# rtlsdr_read_sync
# returns vector of length num_bytes with Uint8 (bytes)
# num_bytes must be multiple of 512
read_bytes(r, num_bytes)

# converts vector of Uint8 into a vector (half as long) of complex iq samples
packed_bytes_to_iq(bytes)

# equivalent to read_bytes + packed_bytes_to_iq
# returns a vector of length num_samples with complex samples
# num_samples must be multiple of 256
read_samples(r, num_samples)
```

[![Build Status](https://travis-ci.org/dressel/RTLSDR.jl.svg?branch=master)](https://travis-ci.org/dressel/RTLSDR.jl)

[![Coverage Status](https://coveralls.io/repos/dressel/RTLSDR.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/dressel/RTLSDR.jl?branch=master)

[![codecov.io](http://codecov.io/github/dressel/RTLSDR.jl/coverage.svg?branch=master)](http://codecov.io/github/dressel/RTLSDR.jl?branch=master)
