%% run_ds000030_analysis

srcpath = '/media/andre/data8t/ds000030/funcpath.txt';
maskpath = '';
outdir = '/media/andre/data8t/ds000030/connectomes';
optspath = '/media/andre/data8t/ds000030/opts.mat';
auxopts = load(optspath);
varname = fieldnames(auxopts);
opts = auxopts.(varname{1});

runapplymask(srcpath,maskpath,outdir,opts)