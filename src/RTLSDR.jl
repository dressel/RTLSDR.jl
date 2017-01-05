module RTLSDR

using DSP: welch_pgram
import Base.open, Base.close

# I'm not sure I want this in here
using PyPlot

export RtlSdr, open, close, read_samples, get_strength, get_strength2
export get_rate, set_rate, get_freq, set_freq

include("c_interface.jl")

type RtlSdr
	valid_ptr::Bool
	dongle_ptr::Ptr{rtlsdr_dev}

	function RtlSdr()
		dp = rtlsdr_open()

		r = new(true, dp)

		# set sample rate and center freq
		set_rate(r, 2.0e6)
		set_freq(r, 88.5e6)

		return r
	end
end

function open(r::RtlSdr, device_index::Int)
end

#close(r::RtlSdr) = rtlsdr_close(r.dongle_ptr)
function close(r::RtlSdr)
	rtlsdr_close(r.dongle_ptr)
	r.valid_ptr = false
end

# Sample rate in MHz
function get_rate(r::RtlSdr)
	@assert r.valid_ptr
	rate = rtlsdr_get_sample_rate(r.dongle_ptr)
	return Int(rate)
end
function set_rate(r::RtlSdr, sample_rate)
	@assert r.valid_ptr
	rtlsdr_set_sample_rate(r.dongle_ptr, sample_rate)
end

# center frequency in MHz
function set_freq(r::RtlSdr, freq)
	@assert r.valid_ptr
	rtlsdr_set_center_freq(r.dongle_ptr, freq)
end
function get_freq(r::RtlSdr)
	@assert r.valid_ptr
	freq = rtlsdr_get_center_freq(r.dongle_ptr)
	return Int(freq)
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

# maximum 
function get_strength(r::RtlSdr, n=10; plot_max::Bool=false)
	max_sample = -Inf
	max_p = 0
	sample_rate = get_rate(r)
	for i = 1:n
		#samples = read_samples(r,256*10240)
		#samples = read_samples(r, 256 * 1024 * 8)
		#samples = read_samples(r,256*1024)
		#samples = read_samples(r,256*940)
		#samples = read_samples(r,256*920)
		#samples = read_samples(r,256*900)
		#samples = read_samples(r,256*800)
		samples = read_samples(r, 256*500)
		#samples = read_samples(r, 256*50)
		p = welch_pgram(samples, fs=sample_rate)
		temp_max = maximum(p.power)
		if temp_max > max_sample 
			max_sample = temp_max
			max_p = deepcopy(p)
		end
	end
	if plot_max
		center_freq = get_freq(r)
		plot(max_p.freq + center_freq, 10log10(max_p.power))
	end
	return 10log10(max_sample)
end



function get_strength2(r::RtlSdr, n=10; plot_max::Bool=false)
	max_sample = -Inf
	max_p = 0
	sample_rate = get_rate(r)
	max_freqs = 0
	max_pows = 0
	for i = 1:n
		samples = read_samples(r, 256*500)
		p = welch_pgram(samples, fs=sample_rate)
		n_plot = round(Int, length(p.power) / 2, RoundDown)-3
		pows = p.power[2:n_plot]
		freqs = p.freq[2:n_plot]

		# taking maximum...
		temp_max = maximum(pows)

		# taking spectrum max...
		temp_max = sum(pows)

		if temp_max > max_sample 
			max_sample = temp_max
			max_p = deepcopy(p)
			max_pows = deepcopy(pows)
			max_freqs = deepcopy(freqs)
		end
	end
	if plot_max
		center_freq = get_freq(r)
		#plot(max_p.freq + center_freq, 10log10(max_p.power))
		plot(max_freqs + center_freq, 10log10(max_pows))
	end
	return 10log10(max_sample*146.)
end


end # module
