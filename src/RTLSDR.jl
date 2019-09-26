module RTLSDR

import Base.open, Base.close

export
    RtlSdr,
    open,
    close,
    read_bytes,
    read_samples,
    packed_bytes_to_iq

export
    get_rate,
    set_rate,
    get_freq,
    set_freq,
    set_agc_mode,
    set_tuner_gain_mode

include("c_interface.jl")

mutable struct RtlSdr
    valid_ptr::Bool
    dongle_ptr::Ptr{rtlsdr_dev}

    function RtlSdr()
        dp = rtlsdr_open()

        r = new(true, dp)

        # default sample rate and center freq
        set_rate(r, 2.0e6)
        set_freq(r, 88.5e6)

        return r
    end
end

function open(r::RtlSdr, device_index::Int)
end

function close(r::RtlSdr)
    rtlsdr_close(r.dongle_ptr)
    r.valid_ptr = false
end

"""
`set_rate(r::RtlSdr, sample_rate_Hz)
"""
function set_rate(r::RtlSdr, sample_rate_Hz)
    @assert r.valid_ptr
    rtlsdr_set_sample_rate(r.dongle_ptr, sample_rate_Hz)
end
function get_rate(r::RtlSdr)
    @assert r.valid_ptr
    rate = rtlsdr_get_sample_rate(r.dongle_ptr)
    return Int(rate)
end

"""
`set_freq(r::RtlSdr, freq_Hz)`

Interface for `rtlsdr_set_center_freq`.
"""
function set_freq(r::RtlSdr, freq_Hz)
    @assert r.valid_ptr
    rtlsdr_set_center_freq(r.dongle_ptr, freq_Hz)
end
function get_freq(r::RtlSdr)
    @assert r.valid_ptr
    freq = rtlsdr_get_center_freq(r.dongle_ptr)
    return Int(freq)
end

"""
Interface for `rtlsdr_set_agc_mode`
"""
function set_agc_mode(r::RtlSdr, mode)
    @assert r.valid_ptr
    rtlsdr_set_agc_mode(r.dongle_ptr, mode)
end

"""
Interface for `rtlsdr_set_tuner_gain_mode`
"""
function set_tuner_gain_mode(r::RtlSdr, manual)
    @assert r.valid_ptr
    rtlsdr_set_tuner_gain_mode(r.dongle_ptr, manual)
end

"""
`read_bytes(r::RtlSdr, num_bytes)`

High-level interface for `rtlsdr_read_sync`.

`num_bytes` must be a multiple of 512.

Returns a vector of length `num_bytes` of Uint8 (bytes).
"""
function read_bytes(r::RtlSdr, num_bytes)
    @assert r.valid_ptr
    return read_bytes(r.dongle_ptr, num_bytes)
end

"""
`read_samples(r::RtlSdr, num_samples)`

Returns a vector of length `num_samples` with complex numbers.
"""
function read_samples(r::RtlSdr, num_samples)
    @assert r.valid_ptr
    num_bytes = 2num_samples
    raw_data = read_bytes(r.dongle_ptr, num_bytes)
    return packed_bytes_to_iq(raw_data)
end

"""
`packed_bytes_to_iq(bytes)`
"""
function packed_bytes_to_iq(bytes)
    num_bytes = length(bytes)
    num_iq = round(Int, num_bytes/2.0, RoundDown)
    iq_vals = zeros(Complex{Float64}, num_iq)
    den = 255.0/2.0

    for i = 1:num_iq
        iq_vals[i] = bytes[2i-1]/den - 1.0 + im*(bytes[2i]/den - 1.0)
    end

    return iq_vals
end


end # module
