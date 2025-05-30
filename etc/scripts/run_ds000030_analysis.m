%% run_ds000030_analysis

% srcpath = '/media/andre/data8t/ds000030/funcpath.txt';
% maskpath = '/media/andre/data8t/ds000030/Schaefer2018_100Parcels_7Networks_3x3x4mm.nii.gz';
% outdir = '/media/andre/data8t/ds000030/connectomes';
% optspath = '/media/andre/data8t/ds000030/opts.mat';

srcpath =  '/media/andre/data8t/ds000030/derivatives/fmriprep/sub-10159/func/sub-10159_task-rest_bold_space-MNI152NLin2009cAsym_preproc.nii.gz';
maskpath = '/media/andre/data8t/ds000030/Schaefer2018_100Parcels_7Networks_3x3x4mm.nii.gz';
outdir = '/media/andre/data8t/ds000030/connectomes';
optspath = '/media/andre/data8t/ds000030/opts1.mat';

clear opts
auxopts = load(optspath);
varname = fieldnames(auxopts);
opts = auxopts.(varname{1});
opts.saveimg = 0;
opts.savestats = 1;
opts.savets = 1;
opts.groupts = 0;

runapplymask(srcpath,maskpath,outdir,opts)

%%

clear opts

roinamespath = [];
opts.rsave = 1;
opts.psave = 1;
opts.zsave = 1;
opts.ftsave = 1;

tspath = '/media/andre/data8t/ds000030/connectomes/timeseries_img-001_mask-001.csv';
outdir = '/media/andre/data8t/ds000030/connectomes/matrices';

runconnectome(tspath,outdir,roinamespath,opts)