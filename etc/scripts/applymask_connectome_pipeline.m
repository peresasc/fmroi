srcpath = 'funcpath.txt';
maskpath = 'Schaefer2018_100Parcels_7Networks_3x3x4mm.nii.gz';
optspath = 'opts.mat';
outdir = 'timeseries_schaefer100';


%==========================================================================
%                            Apply Mask
%==========================================================================
clear opts

% load the default cleaning time series parameters
% If no cleaning is needed just coment the lines below
auxopts = load(optspath);
varname = fieldnames(auxopts);
opts = auxopts.(varname{1});

% mandatory options for running applymask
% use opts.groupts = 1 if you have several binary masks for each subject
opts.saveimg = 0;
opts.savestats = 1;
opts.savets = 1;
opts.groupts = 0;

runapplymask(srcpath,maskpath,outdir,opts)

%==========================================================================
%                            Connectome
%==========================================================================
clear opts

% path to the time series extracted by runapplymask
tspath = '/schaefer100/timeseries/timeseriestab_mask-001.mat';
outdir = '/schaefer100/connectomes';

roinamespath = []; % let this way if you don't want to create labels for ploting connectomes
opts.rsave = 1;
opts.psave = 1;
opts.zsave = 1; % saves fisher trandform, we'll use this in the SVM analysis
opts.ftsave = 1; % generate the feature matrix read-to-use in SVM

runconnectome(tspath,outdir,roinamespath,opts)