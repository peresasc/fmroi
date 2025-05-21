function tsfilt = preproc_butter(ts,hp,lp,tr,n)
%
%
% Author: Andre Peres, 2025, peres.asc@gmail.com
% Last update: Andre Peres, 21/05/2025, peres.asc@gmail.com

fs = 1/tr;  % Sampling frequency in Hz
ts = ts';
if isnan(hp) && isnan(lp) % No filter is applied
    tsfilt = ts;

elseif isnan(lp) % high-pass filter
    % Normalize cutoff frequencies based on the Nyquist frequency
    Wn = hp/(fs/2);

    if Wn <= 0 || Wn >= 1
        error('Invalid highpass cutoff frequency relative to sampling rate.');
    end

    [b,a] = butter(n,Wn,'high');
    tsfilt = filtfilt(b,a,ts);  % Apply zero-phase high-pass filter

elseif isnan(hp) % low-pass filter
    % Normalize cutoff frequencies based on the Nyquist frequency
    Wn = lp/(fs/2);

    if Wn <= 0 || Wn >= 1
        error('Invalid lowpass cutoff frequency relative to sampling rate.');
    end

    [b, a] = butter(1, Wn, 'low');
    tsfilt = filtfilt(b, a, ts);  % Apply zero-phase low-pass filter

else % band-pass filter
    % Normalize cutoff frequencies based on the Nyquist frequency
    Wn = [hp lp]/(fs/2);

    % Validate bandpass range
    if Wn(1) >= Wn(2) || Wn(1) <= 0 || Wn(2) >= 1
        error(['Invalid bandpass range: check highpass and lowpass ',...
            'values relative to sampling rate.']);
    end

    % Design first-order Butterworth bandpass filter
    [b,a] = butter(1,Wn,'bandpass');

    % Apply zero-phase filtering (forward and reverse) to avoid phase distortion
    tsfilt = filtfilt(b,a,ts);
end

tsfilt = tsfilt';