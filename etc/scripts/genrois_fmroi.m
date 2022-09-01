%% spheremask
outdir = '/home/andre/github/tmp/fmroi_qc/dataset/fmroi-spheremask';
if ~isfolder(outdir)
    mkdir(outdir)
end

vsrc = spm_vol('/home/andre/github/fmroi/templates/FreeSurfer/cvs_avg35_inMNI152/T1.nii.gz');
srcvol = spm_data_read(vsrc);
sig = [-1 1];
for r = 1:100
    disp(['Creating ROI ',num2str(r)]);

    x = (sig(randperm(2,1))*randperm(round(size(srcvol,1)/2-r-3),1))...
        +round(size(srcvol,1)/2);
    y = (sig(randperm(2,1))*randperm(round(size(srcvol,2)/2-r-3),1))...
        +round(size(srcvol,2)/2);
    z = (sig(randperm(2,1))*randperm(round(size(srcvol,3)/2-r-3),1))...
        +round(size(srcvol,3)/2);
    curpos = [x,y,z];

    roi = spheremask(srcvol,curpos,r,'radius');

    vsrc.fname = fullfile(outdir,['spheremask_radius_',sprintf('%03d',r),...
        '_center_x',sprintf('%03d',x),'y',sprintf('%03d',y),...
        'z',sprintf('%03d',z),'.nii']);

    V = spm_create_vol(vsrc);
    V.pinfo = [1;0;0]; % avoid SPM to rescale the masks
    V = spm_write_vol(V,roi);
end

%--------------------------------------------------------------------------
%% cubicmask

outdir = '/home/andre/github/tmp/fmroi_qc/dataset/fmroi-cubicmask_even';
if ~isfolder(outdir)
    mkdir(outdir)
end

vsrc = spm_vol('/home/andre/github/fmroi/templates/FreeSurfer/cvs_avg35_inMNI152/T1.nii.gz');
srcvol = spm_data_read(vsrc);
sig = [-1 1];
for r = 2:2:200
    disp(['Creating ROI ',num2str(r)]);

    x = (sig(randperm(2,1))*randperm(round(size(srcvol,1)/2-r/2-3),1))...
        +round(size(srcvol,1)/2);
    y = (sig(randperm(2,1))*randperm(round(size(srcvol,2)/2-r/2-3),1))...
        +round(size(srcvol,2)/2);
    z = (sig(randperm(2,1))*randperm(round(size(srcvol,3)/2-r/2-3),1))...
        +round(size(srcvol,3)/2);
    curpos = [x,y,z];

    roi = cubicmask(srcvol,curpos,r,'edge');

    vsrc.fname = fullfile(outdir,['cubicmask_edge_',sprintf('%03d',r),...
        '_center_x',sprintf('%03d',x),'y',sprintf('%03d',y),...
        'z',sprintf('%03d',z),'.nii']);

    V = spm_create_vol(vsrc);
    V.pinfo = [1;0;0]; % avoid SPM to rescale the masks
    V = spm_write_vol(V,roi);
end

%% img2mask_syndata

outdir = '/home/andre/github/tmp/fmroi_qc/dataset/fmroi-img2mask_syndata';
if ~isfolder(outdir)
    mkdir(outdir)
end

vsrc = spm_vol('/home/andre/github/fmroi/templates/syndata/syntheticdata.nii');
srcvol = spm_data_read(vsrc);

thr = [1,1;3,4;5,5;5.2,5.2;5.4,5.4;5.6,5.6;5.8,5.8;7,8;9,10;11,12];

for i = 1:size(thr,1)
    
    roi = img2mask(srcvol,thr(i,1),thr(i,2));

    vsrc.fname = fullfile(outdir,['fmroi-img2mask_threshold_',...
        sprintf('%02d',thr(i,1)),'_',sprintf('%02d',thr(i,2)),'.nii']);

    V = spm_create_vol(vsrc);
    V.pinfo = [1;0;0]; % avoid SPM to rescale the masks
    V = spm_write_vol(V,roi);
end

%% img2mask_dmn

outdir = '/home/andre/github/tmp/fmroi_qc/dataset/fmroi-img2mask_dmn';
if ~isfolder(outdir)
    mkdir(outdir)
end

vsrc = spm_vol('/home/andre/github/fmroi/etc/default_templates/Neurosynth/default mode_association-test_z_FDR_0.01.nii.gz');
srcvol = spm_data_read(vsrc);

thr = max(srcvol(:))*rand(100,2);

for i = 1:size(thr,1)
    
    disp(['Creating ROI ',num2str(i)]);
    roi = img2mask(srcvol,thr(i,1),thr(i,2));

    vsrc.fname = fullfile(outdir,['fmroi-img2mask_threshold_',...
        sprintf('%02d',thr(i,1)),'_',sprintf('%02d',thr(i,2)),'.nii']);

    V = spm_create_vol(vsrc);
    V.pinfo = [1;0;0]; % avoid SPM to rescale the masks
    V = spm_write_vol(V,roi);
end

%% clustermask

outdir = '/home/andre/github/tmp/fmroi_qc/dataset/fmroi-clustermask';
if ~isfolder(outdir)
    mkdir(outdir)
end

vsrc = spm_vol('/home/andre/github/fmroi/templates/syndata/syntheticdata.nii');
srcvol = spm_data_read(vsrc);

roi = contiguousclustering(srcvol,.1,12,1);
nrois = unique(roi(:));
nrois(nrois==0) = [];

for i = 1:length(nrois)
    binmask = uint16(roi==nrois(i));

    vsrc.fname = fullfile(outdir,['fmroi-clustermask_',...
        sprintf('%03d',nrois(i)),'.nii']);

    V = spm_create_vol(vsrc);
    V.pinfo = [1;0;0]; % avoid SPM to rescale the masks
    V = spm_write_vol(V, binmask);
end
