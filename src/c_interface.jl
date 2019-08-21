######################################################################
# c_interface.jl
######################################################################

# internal pointer for ccall stuff
mutable struct rtlsdr_dev
end

# returns a pointer to 
function rtlsdr_open()
	index = 0
	rd = Array{Ptr{rtlsdr_dev},1}(undef,1)
	ret = ccall( (:rtlsdr_open, "librtlsdr"), Cint, (Ptr{Ptr{rtlsdr_dev}}, UInt32), rd, index)

	if ret < -1; error("RTLSDR.jl reports: Error opening device."); end

	rf = rd[1]

	# resetting buffers is critical to reading bytes
	ret = ccall( (:rtlsdr_reset_buffer, "librtlsdr"), Cint, (Ref{rtlsdr_dev},), rf)
	if ret < -1; error("RTLSDR.jl reports: Error resetting buffer."); end

	return rf
end

function rtlsdr_close(rf::Ref{rtlsdr_dev})
	ccall( (:rtlsdr_close, "librtlsdr"), Cint, (Ref{rtlsdr_dev},), rf)
end

# center frequency
function rtlsdr_set_center_freq(rf::Ref{rtlsdr_dev}, freq)
	ccall( (:rtlsdr_set_center_freq, "librtlsdr"), Cint, (Ref{rtlsdr_dev}, UInt32), rf, Cint(freq))
end

function rtlsdr_get_center_freq(rf::Ref{rtlsdr_dev})
	ccall( (:rtlsdr_get_center_freq, "librtlsdr"), UInt32, (Ref{rtlsdr_dev},), rf)
end

# sample rate
function rtlsdr_get_sample_rate(rf::Ref{rtlsdr_dev})
	ccall( (:rtlsdr_get_sample_rate, "librtlsdr"), UInt32, (Ref{rtlsdr_dev},), rf)
end

function rtlsdr_set_sample_rate(rf::Ref{rtlsdr_dev}, sample_rate)
	ccall( (:rtlsdr_set_sample_rate, "librtlsdr"), Cint, (Ref{rtlsdr_dev},UInt32), rf, sample_rate)
end




# Some I/O stuff
function read_bytes(rf::Ref{rtlsdr_dev}, num_bytes)

	buf = Vector{Cuchar}(undef,num_bytes)
	bytes_read = Ref{Cint}(0)
	#println("a was ", bytes_read[])
	ret = ccall( (:rtlsdr_read_sync, "librtlsdr"), Int32, (Ref{rtlsdr_dev}, Ref{Cuchar}, Cint, Ref{Cint}), rf, buf, num_bytes, bytes_read)
	#println("ret was: ", ret); println("a is ", bytes_read[])

	return buf
end
