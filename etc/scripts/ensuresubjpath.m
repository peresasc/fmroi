%% load_paths
funcpath = '/media/andre/data8t/ds000030/funcpath.txt';
funcpath = readcell(funcpath,'Delimiter',[";",'\t']);

confpath = '/media/andre/data8t/ds000030/confpath.txt';
confpath = readcell(confpath,'Delimiter',[";",'\t']);

selconfpath = '/media/andre/data8t/ds000030/selconfpath.txt';
selconfpath = readcell(selconfpath,'Delimiter',[";",'\t']);

%% save_selected_confounds
confsz = zeros(length(confpath),2);
for i = 1:length(confpath)
    curconf = confpath{i};
    [pn,fn,ext] = fileparts(curconf);

    conftable = readtable(curconf,'FileType','delimitedtext');
    conf = table2array(conftable);
    selcols = ~any(isnan(conf));
    conf = conf(:,selcols);
    confsz(i,:) = size(conf);
    writematrix(conf, fullfile(pn,[fn,'_selected.csv']),'Delimiter','tab');
end
disp('DONE!!')

%%
% confpath = selconfpath;
if length(funcpath) ~= length(confpath)
    error(['The number of functional image paths does not match the number of confounds files.', ...
       newline, 'Please ensure that each subject''s functional data has a corresponding confound file.']);
end

subjcmp = zeros(length(funcpath),1);
for i = 1:length(funcpath)
    curfunc = funcpath{i};
    f = strfind(curfunc, '_task-rest_bold');
    a = curfunc(1:f-1);

    curconf = confpath{i};
    c = strfind(curconf, '_task-rest_bold');
    b = curconf(1:c-1);

    subjcmp(i) = strcmpi(a,b);
end
if any(subjcmp == 0)
    error(['Subject ID mismatch between functional images and confound paths.', ...
        newline, 'Please ensure each functional image is paired with the correct confound based on subject ID.']);
else
    disp('Subject IDs in functional images and confounds are properly matched.');
end

%% 

% Paths
source_nii = '/home/andre/tmp/applymask_test/ds30/Schaefer2018_100Parcels_7Networks_order_FSLMNI152_2mm.nii';       % atlas original 2x2x2mm
target_nii = '/home/andre/tmp/applymask_test/ds30/sub-10159_task-rest_bold_space-MNI152NLin2009cAsym_brainmask.nii';   % imagem fMRI 3x3x4mm
resampled_nii = '/home/andre/tmp/applymask_test/ds30/Schaefer2018_100Parcels_7Networks_order_FSLMNI152_resampled.nii';

%% spm_covert_to_fmri_shape
% Use SPM's reslice function

spm('defaults','fmri');
spm_jobman('initcfg');

matlabbatch{1}.spm.spatial.coreg.write.ref = {target_nii};
matlabbatch{1}.spm.spatial.coreg.write.source = {source_nii};
matlabbatch{1}.spm.spatial.coreg.write.roptions.interp = 0;  % nearest neighbor (preserve labels)
matlabbatch{1}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.coreg.write.roptions.mask = 0;
matlabbatch{1}.spm.spatial.coreg.write.roptions.prefix = 'r_';

spm_jobman('run', matlabbatch);

% The resampled atlas will be saved as 'r_atlas_2mm.nii'
movefile('r_atlas_2mm.nii', resampled_nii);


%% matlab_covert_to_fmri_shape

% Load volumes
srcvol = spm_vol(source_nii);
trgvol = spm_vol(target_nii);

srcdata = spm_read_vols(srcvol);
trgdata = spm_read_vols(trgvol);

% Get target size
trgsz = size(trgdata);

% Compute new voxel size ratio
resize_factor = size(srcdata)./trgsz;

% Resize using nearest-neighbor interpolation
resampled_src = imresize3(srcdata, trgsz(1:3), 'nearest');
resampled_src = flip(resampled_src, 1); 


% Create new header (based on fMRI image)
new_hdr = trgvol(1);
new_hdr.fname = resampled_nii;
new_hdr.descrip = 'Atlas resampled to fMRI resolution';

% Save resampled atlas
spm_write_vol(new_hdr, resampled_src);


%% get_confounds_fmriprep
varNames = conftable.Properties.VariableNames;

gs = contains(varNames, 'global', 'IgnoreCase', true);
wm = contains(varNames, 'csf', 'IgnoreCase', true);
csf = contains(varNames, 'white', 'IgnoreCase', true);
compcor = contains(varNames, 'comp', 'IgnoreCase', true);
trans = contains(varNames, 'trans', 'IgnoreCase', true);
rot = contains(varNames, 'rot', 'IgnoreCase', true);

sel = wm | csf | compcor | trans | rot;

deriv = contains(varNames, 'derivative', 'IgnoreCase', true);
sel = sel & ~deriv; 

selvars = varNames(sel);

selconf = table2array(conftable(:, selvars));
writematrix(selconf, 'confounds_selected.csv', 'Delimiter', 'tab');


