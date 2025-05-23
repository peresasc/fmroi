function regout_ts = preproc_regout(ts,conf,selconf,demean)

% Transpose fMRI to be (t x n_voxels) for regression
ts = double(ts');  % (t x n_voxels)

if ~isempty(selconf)
    conf = double(conf(selconf));  % design matrix (t x n_confounds)
end

if ~isempty(conf) && size(ts,1) ~= size(conf,1)
    he = errordlg(['The number of time points in the confound matrix ',...
        'must match the number of time points in the time series.'],...
        'Invalid Input');
    uiwait(he)
    return
end

% Add intercept (constant regressor)
if demean
    conf = [conf, ones(size(ts,1),1)];  % (t x (n_confounds + 1))
end

%--------------------------------------------------------------------------
% Solve GLM: get residuals after regressing out confounds
beta = conf \ ts;             % (n_confounds+1 x n_voxels)
tspred = conf * beta;         % predicted signal
residuals = ts - tspred;    % residuals = cleaned signal

% Transpose back to (n_voxels x t)
regout_ts = residuals';