######################################################################
# c_interface.jl
######################################################################

# internal pointer for ccall stuff
mutable struct rtlsdr_dev
end

mutable struct RTLSDRError <: Exception
    message::String
end

# returns a pointer to 
function rtlsdr_open()
    index = 0
    rd = Array{Ptr{rtlsdr_dev},1}(undef,1)
    ret = ccall( (:rtlsdr_open, "librtlsdr"),
                 Cint,
                 (Ptr{Ptr{rtlsdr_dev}}, UInt32),
                 rd,
                 index
               )

    if ret != 0; throw(RTLSDRError("RTLSDR.jl reports: Error opening device.")); end

    rf = rd[1]

    # resetting buffers is critical to reading bytes
    rtlsdr_reset_buffer(rf)

    return rf
end

function rtlsdr_reset_buffer(rf::Ref{rtlsdr_dev})
    ret = ccall( (:rtlsdr_reset_buffer, "librtlsdr"),
                 Cint,
                 (Ref{rtlsdr_dev},),
                 rf
               )
    if ret != 0; throw(RTLSDRError("RTLSDR.jl reports: Error resetting buffer (error code $ret).")); end
end

function rtlsdr_close(rf::Ref{rtlsdr_dev})
    ret = ccall( (:rtlsdr_close, "librtlsdr"), Cint, (Ref{rtlsdr_dev},), rf)
    if ret != 0; throw(RTLSDRError("RTLSDR.jl reports: Error closing device (error code $ret).")); end
end

# center frequency
function rtlsdr_set_center_freq(rf::Ref{rtlsdr_dev}, freq)
    ret = ccall( (:rtlsdr_set_center_freq, "librtlsdr"), Cint, (Ref{rtlsdr_dev}, UInt32), rf, Cint(freq))
    if ret != 0; throw(RTLSDRError("RTLSDR.jl reports: Error setting center frequency (error code $ret).")); end
end

function rtlsdr_get_center_freq(rf::Ref{rtlsdr_dev})
    ret = ccall( (:rtlsdr_get_center_freq, "librtlsdr"), UInt32, (Ref{rtlsdr_dev},), rf)
    if ret < 0
        throw(RTLSDRError("RTLSDR.jl reports: Error getting center frequency (error code $ret)."));
    end
    return ret
end

# sample rate
function rtlsdr_get_sample_rate(rf::Ref{rtlsdr_dev})
    ret = ccall( (:rtlsdr_get_sample_rate, "librtlsdr"),
                 UInt32, 
                 (Ref{rtlsdr_dev},), 
                 rf
               )
    if ret < 0
        throw(RTLSDRError("RTLSDR.jl reports: Error getting sample rate (error code $ret)."));
    end
    return ret
end

function rtlsdr_set_sample_rate(rf::Ref{rtlsdr_dev}, sample_rate)
    ret = ccall( (:rtlsdr_set_sample_rate, "librtlsdr"),
                 Cint,
                 (Ref{rtlsdr_dev},UInt32), 
                 rf, 
                 sample_rate
               )
    if ret != 0; throw(RTLSDRError("RTLSDR.jl reports: Error satting sample rate (error code $ret).")); end
end

# gain
function rtlsdr_set_agc_mode(rf::Ref{rtlsdr_dev}, on)
    ret = ccall( (:rtlsdr_set_tuner_gain, "librtlsdr"),
                 Cint,
                 (Ref{rtlsdr_dev},Cint),
                 rf, 
                 on
                )
    if ret != 0; throw(RTLSDRError("RTLSDR.jl reports: Error setting AGC mode (error code $ret).")); end
end

function rtlsdr_set_tuner_gain_mode(rf::Ref{rtlsdr_dev}, manual)
    ret = ccall( (:rtlsdr_set_tuner_gain_mode, "librtlsdr"),
                 Cint,
                 (Ref{rtlsdr_dev},Cint),
                 rf,
                 manual
               )
    if ret != 0; throw(RTLSDRError("RTLSDR.jl reports: Error setting tuner gain mode (error code $ret).")); end
end

function rtlsdr_set_tuner_gain(rf::Ref{rtlsdr_dev}, gain)
    ret = ccall( (:rtlsdr_set_tuner_gain, "librtlsdr"),
                 Cint,
                 (Ref{rtlsdr_dev},Cint),
                 rf,
                 gain
               )
    if ret != 0; throw(RTLSDRError("RTLSDR.jl reports: Error setting tuner gain (error code $ret).")); end
end

function rtlsdr_get_tuner_gain(rf::Ref{rtlsdr_dev})
    gain = Array{Cint,1}(undef,1)
    ret = ccall( (:rtlsdr_get_tuner_gain, "librtlsdr"),
                 Cint,
                 (Ref{rtlsdr_dev},Ptr{Cint}),
                 rf,
                 gain
               )
    if ret != 0; throw(RTLSDRError("RTLSDR.jl reports: Error getting tuner gain (error code $ret).")); end
    return gain[1]
end


function read_bytes(rf::Ref{rtlsdr_dev}, num_bytes)
    buf = Vector{Cuchar}(undef,num_bytes)
    bytes_read = Ref{Cint}(0)
    ret = ccall( (:rtlsdr_read_sync, "librtlsdr"),
                 Int32,
                 (Ref{rtlsdr_dev}, Ref{Cuchar}, Cint, Ref{Cint}),
                 rf,
                 buf,
                 num_bytes,
                 bytes_read
                )
    if ret != 0; throw(RTLSDRError("RTLSDR.jl reports: Error while reading from device (error code $ret).")); end

    return buf
end
