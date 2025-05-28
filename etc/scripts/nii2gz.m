%%
[fn, pn, idx] = uigetfile('*.nii',...
    'Select one or more Nifti files to be compressed', ...
    'MultiSelect', 'on');

outdir = fullfile(pn,'compressed');
if ~isfolder(outdir)
    mkdir(outdir)
end

for i = 1:length(fn)
    niipath = fullfile(pn,fn{i});
    gzip(niipath,outdir);
end

disp('DONE!!')