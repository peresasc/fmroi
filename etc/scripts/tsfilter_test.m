%%
% Supondo que:
% fmri4D  -> matriz 4D de dados fMRI com dimensões (x, y, z, t)
% mask3D  -> máscara lógica ou binária com dimensões (x, y, z)
tic
fmri4D = srcdata;
fmri3D = squeeze(fmri4D(:,:,:,1));
mask3D = mask;
% Verifique dimensões compatíveis
if ~isequal(size(fmri4D,1:3), size(mask3D))
    error('Mask and fMRI volume dimensions do not match.');
end

% Converte o fMRI 4D para 2D: (n_voxels_total, t)
[x, y, z, t] = size(fmri4D);
fmri2D = reshape(fmri4D, [], t);  % reshape para (x*y*z, t)

% Achando os índices dos voxels dentro da máscara
% mask1D = mask3D(:);  % vetor lógico 1D com (x*y*z, 1)
mask1D = fmri3D(:);
% Aplicando a máscara: mantém apenas os voxels desejados
timeseries = fmri2D(logical(mask1D), :);  % (n_voxels_masked, t)
toc

%%
tic
ts = timeseries';
hp = 0.001;
lp = 0.08;
tr = 2;

fs = 1/tr;  % Sampling frequency in Hz

if isnan(hp) && isnan(lp) % No filter is applied
    tsfilt = ts;

elseif isnan(lp) % high-pass filter
    % Normalize cutoff frequencies based on the Nyquist frequency
    Wn = hp/(fs/2);

    if Wn <= 0 || Wn >= 1
        error('Invalid highpass cutoff frequency relative to sampling rate.');
    end

    [b,a] = butter(1,Wn,'high');
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

toc