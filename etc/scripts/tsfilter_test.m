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
ts = ts';
hp = 0.001;
lp = 0.08;
tr = 1;

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
    % figure
    % freqz(b,a)

    % Apply zero-phase filtering (forward and reverse) to avoid phase distortion
    tsfilt = filtfilt(b,a,ts);
end


[H, f] = freqz(b, a, 1024, fs);  % agora 'f' está em Hz

% Plot customizado
figure;
plot(f, abs(H));
xlabel('Frequency (Hz)');
ylabel('Magnitude');
title('Frequency response (Hz) of high-pass Butterworth filter');
grid on;

toc
%%
confounds = readtable("/home/andre/tmp/applymask_test/maismemoria/sub-01_ses-01_task-rest_desc-confounds_regressors.csv");
varNames = confounds.Properties.VariableNames;

% Buscar por 'compcor' ou 'csf' nos nomes das variáveis (case-insensitive)
wm = contains(varNames, 'csf', 'IgnoreCase', true);
csf = contains(varNames, 'white_matter', 'IgnoreCase', true);
compcor = contains(varNames, 'comp_cor', 'IgnoreCase', true);
trans = contains(varNames, 'trans', 'IgnoreCase', true);
rot = contains(varNames, 'rot', 'IgnoreCase', true);


% Combinar os dois critérios
sel = wm | csf | compcor | trans | rot;

% Obter os nomes das variáveis correspondentes
selvars = varNames(sel);

% Extrair os dados numéricos das colunas selecionadas
selconf = table2array(confounds(:, selvars));
selconf = nan2num(selconf);

% Salvar como CSV sem cabeçalho (apenas os valores)
writematrix(selconf, 'confounds_selected.csv', 'Delimiter', 'tab');
% clearvars -except selconf
%%
tic
X = double(selconf);  % design matrix (t x n_confounds)

% Add intercept (constant regressor)
X = [X, ones(size(X,1),1)];  % (t x (n_confounds + 1))

% Transpose fMRI to be (t x n_voxels) for regression
Y = double(auxts');  % (t x n_voxels)

% Solve GLM: get residuals after regressing out confounds
beta = X \ Y;             % (n_confounds+1 x n_voxels)
Y_hat = X * beta;         % predicted signal
residuals = Y - Y_hat;    % residuals = cleaned signal

% Transpose back to (n_voxels x t)
auxts = residuals';
toc
% Result:
% cleaned_fmri is the confound-regressed fMRI data of size (n_voxels, t)

%%
tic
infmri = '/home/andre/tmp/applymask_test/maismemoria/fmroi_cleanglm.nii';
outfmri = '/home/andre/tmp/applymask_test/maismemoria/fmroi_cleanglm_smooth.nii';
spm_smooth(infmri, outfmri, [6 6 6]);
toc

%%

smoothed4D = zeros(size(fmri4D), 'like', fmri4D);
for t = 1:size(fmri4D, 4)
    smoothed4D(:,:,:,t) = imbilatfilt3(fmri4D(:,:,:,t), 2, 0.1);  % ajuste os parâmetros
end