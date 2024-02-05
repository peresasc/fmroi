%% paths_definition
%==========================================================================
% ROI Generation Script for fMROI Software
%
%---------------------------------------------------------------------------
% This script is designed to generate Region of Interests (ROIs) using the
% fMROI software. It serves as part of the testing suite for assessing the
% functionality and performance of fMROI in creating ROIs. The generated
% ROIs were used to evaluate its accuracy, reproducibility, and robustness,
% as reported in the paper "fMROI: a simple and adaptable toolbox for easy
% region-of-interest creation," currently under review.
%
% To execute the script "genrois_fmroi", fMROI must be installed and
% executed at least once in the MATLAB session to create the ROIs. You can
% run the entire script to generate ROIs for the algorithms spheremask,
% cubicmask, img2mask, contiguousclustering, maxkmask, and 
% regiongrowingmask in a single execution or run them individually within
% each cell. Always remember to execute the first cell "paths_definition" 
% before any ROI creation algorithm.
%
% Author: Andre Peres, 2024.
%==========================================================================



datarootdir = '/media/andre/data8t/fmroi/fmroi_qc/dataset';

[fmroirootdir,~,~] = fileparts(which('fmroi'));
templatesdir = fullfile(fmroirootdir,'etc','test_data');

%% spheremask
clearvars -except datarootdir templatesdir

outdir = fullfile(datarootdir,'fmroi-spheremask');
if ~isfolder(outdir)
    mkdir(outdir)
end

% FreeSurfer cvs_avg35_inMNI152 T1 isovoxel 1mm, 256x256x256
srcpath = fullfile(templatesdir,'T1.nii.gz');

vsrc = spm_vol(srcpath);
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

    fname = fullfile(outdir,['fmroi-spheremask_srcimg_t1_radius_',...
        sprintf('%03d',r),'_center_x',sprintf('%03d',x),...
        'y',sprintf('%03d',y),'z',sprintf('%03d',z),'.nii']);

    [~] = spheremask(srcpath,curpos,r,'radius',fname);
end

%--------------------------------------------------------------------------
%% cubicmask
clearvars -except datarootdir templatesdir

outdir = fullfile(datarootdir,'fmroi-cubicmask');
if ~isfolder(outdir)
    mkdir(outdir)
end

% FreeSurfer cvs_avg35_inMNI152 T1 isovoxel 1mm, 256x256x256
srcpath = fullfile(templatesdir,'T1.nii.gz');

vsrc = spm_vol(srcpath);
srcvol = spm_data_read(vsrc);
sig = [-1 1];
for r = 1:100
    disp(['Creating ROI ',num2str(r)]);

    x = (sig(randperm(2,1))*randperm(round(size(srcvol,1)/2-r/2-3),1))...
        +round(size(srcvol,1)/2);
    y = (sig(randperm(2,1))*randperm(round(size(srcvol,2)/2-r/2-3),1))...
        +round(size(srcvol,2)/2);
    z = (sig(randperm(2,1))*randperm(round(size(srcvol,3)/2-r/2-3),1))...
        +round(size(srcvol,3)/2);
    curpos = [x,y,z];

    fname = fullfile(outdir,['fmroi-cubicmask_srcimg_t1_edge_',...
        sprintf('%03d',r),'_center_x',sprintf('%03d',x),'y',...
        sprintf('%03d',y),'z',sprintf('%03d',z),'.nii']);

    [~] = cubicmask(srcpath,curpos,r,'edge',fname);
end

%% img2mask
% complex-shapes
clearvars -except datarootdir templatesdir

outdir = fullfile(datarootdir,'fmroi-img2mask');
if ~isfolder(outdir)
    mkdir(outdir)
end

% Synthetic data with several shapes isovoxel 2mm, 91x109x91
srcpath = fullfile(templatesdir,'complex-shapes.nii.gz');

thr = [1,1;3,4;5,5;5.2,5.2;5.4,5.4;5.6,5.6;5.8,5.8;7,8;9,10;11,12];

for i = 1:size(thr,1)

    fname = fullfile(outdir,[...
        'fmroi-img2mask_srcimg_syndata_threshold_',...
        sprintf('%02d',thr(i,1)),'_',sprintf('%02d',thr(i,2)),'.nii']);

    [~] = img2mask(srcpath,thr(i,1),thr(i,2),fname);
end

% DMN Neurosinth data with isovoxel 2mm, 91x109x91
srcpath = fullfile(templatesdir,...
    'default_mode_association-test_z_FDR_0.01.nii.gz');

vsrc = spm_vol(srcpath);
srcvol = spm_data_read(vsrc);

thr = max(srcvol(:))*rand(100,2);

for i = 1:size(thr,1)
    
    disp(['Creating ROI ',num2str(i)]);

    fname = fullfile(outdir,[...
        'fmroi-img2mask_srcimg_dmn_threshold_',...
        sprintf('%02d',thr(i,1)),'_',sprintf('%02d',thr(i,2)),'.nii']);

    [~] = img2mask(srcpath,thr(i,1),thr(i,2),fname);
end

%% clustermask
clearvars -except datarootdir templatesdir

outdir = fullfile(datarootdir,'fmroi-clustermask');
if ~isfolder(outdir)
    mkdir(outdir)
end

% Synthetic data with 64 spheres isovoxel 2mm, 91x109x91
srcpath = fullfile(templatesdir,'64-spheres.nii.gz');

vsrc = spm_vol(srcpath);
srcvol = spm_data_read(vsrc);

thrs = [.1,inf;17,32;33,inf];
mincsz = [1,33,123];

for i = 1:size(thrs,1)
    roi = contiguousclustering(srcvol,thrs(i,1),thrs(i,2),mincsz(i));
    nrois = unique(roi(:));
    nrois(nrois==0) = [];

    for n = 1:length(nrois)
        binmask = uint16(roi==nrois(n));

        vsrc.fname = fullfile(outdir,[...
            'fmroi-clustermask_srcimg_spheres',...
            '_threshold_',num2str(thrs(i,1)),'_',num2str(thrs(i,2))...
            '_mincsz_',num2str(mincsz(i)),...
            '_cluster_',sprintf('%03d',nrois(n)),'.nii']);

        V = spm_create_vol(vsrc);
        V.pinfo = [1;0;0]; % avoid SPM to rescale the masks
        V = spm_write_vol(V, binmask);
    end
end

%% maxkmask
clearvars -except datarootdir templatesdir

outdir = fullfile(datarootdir,'fmroi-maxkmask');
if ~isfolder(outdir)
    mkdir(outdir)
end

% DMN Neurosinth gaussian noise added with isovoxel 2mm, 91x109x91
srcpath = fullfile(templatesdir,...
    'default_mode_association-test_z_FDR_0.01_gaussnoise_5db.nii.gz');

% FreeSurfer cvs_avg35_inMNI152 aparc+aseg isovoxel 2mm, 91x109x91
prepath = fullfile(templatesdir,'aparc+aseg_2mm.nii.gz');
vpre = spm_vol(prepath);
prevol = spm_data_read(vpre);

pmidx = unique(prevol(:));
pmidx(pmidx==0) = [];

for i = 1:length(pmidx)
    disp(['Creating ROI ',num2str(i)]);

    premask = prevol==pmidx(i);
    kvox = randperm(sum(premask(:)),1);
    
    fname = fullfile(outdir,[...
        'fmroi-maxkmask_srcimg_dmnnoise_premask_aparcaseg_premaskidx_',...
        sprintf('%04d',pmidx(i)),'_kvox_',sprintf('%01d',kvox),'.nii']);

    [~] = maxkmask(srcpath,premask,kvox,fname);
end

%% regiongrowing
clearvars -except datarootdir templatesdir

outdir = fullfile(datarootdir,'fmroi-regiongrowing');
if ~isfolder(outdir)
    mkdir(outdir)
end

% Synthetic data with several shapes isovoxel 2mm, 91x109x91
srcpath = fullfile(templatesdir,'complex-shapes.nii.gz');

vsrc = spm_vol(srcpath);
srcvol = spm_data_read(vsrc);

%--------------------------------------------------------------------------
% spirals test
seed = [46,84,50;46,84,50;46,84,50;46,84,49];
diffratio = inf;
grwmode = {'ascending';'descending';'similarity';'similarity'};
nvox = {round(linspace(31,221,20));...
        round(linspace(21,116,20));...
        round(linspace(23,221,10));...
        round(linspace(16,115,10))};

% premask = srcvol;
count = 0;
for i = 1:length(grwmode)
    for j = 1:length(nvox{i})
        count = count+1;

        disp(['Creating ROI ',grwmode{i},' ',num2str(count)]);
      
        seedstr = num2str(sub2ind(size(srcvol),seed(i,1),seed(i,2),seed(i,3)));
        fname = fullfile(outdir,['fmroi-regiongrowing',...
            '_srcimg_syndata',...
            '_seed_',seedstr,...
            '_diffratio_',num2str(diffratio),...
            '_grwmode_',grwmode{i},...
            '_nvox_',num2str(nvox{i}(j)),...
            '_premask_srcvol.nii']);            

  
        [~] = regiongrowingmask(srcpath,seed(i,:),diffratio,...
                                grwmode{i},nvox{i}(j),srcpath,fname);
 
    end
end

%--------------------------------------------------------------------------
% shapes test
clearvars -except templatesdir srcpath outdir srcvol count

thr = [1,1;3,4;5,5;5.2,5.2;5.4,5.4;5.6,5.6;5.8,5.8;7,8;9,10;11,12];
grwmode = {'ascending';'descending';'similarity'};
nvox = inf;

for i = 1:length(grwmode)
    for j = 1:size(thr,1)
        count = count + 1;
        disp(['Creating ROI ',grwmode{i},' ',num2str(count)]);

        roipos = find(srcvol>=thr(j,1) & srcvol<=thr(j,2));
        sidx = randperm(length(roipos),1);
        [x,y,z] = ind2sub(size(srcvol),roipos(sidx));
        seed = [x,y,z];

        diffratio = abs(diff(thr(j,:)));
        if diffratio == 0
            diffratio = 0.001;
        end

        seedstr = num2str(sub2ind(size(srcvol),seed(1),seed(2),seed(3)));
        fname = fullfile(outdir,['fmroi-regiongrowing',...
            '_srcimg_syndata',...
            '_seed_',seedstr,...
            '_diffratio_',num2str(diffratio),...
            '_grwmode_',grwmode{i},...
            '_nvox_',num2str(nvox),...
            '_premask_srcvol.nii']);            

      
        [~] = regiongrowingmask(srcpath,seed,diffratio,...
                                grwmode{i},nvox,srcpath,fname);

    end
end

%--------------------------------------------------------------------------
% shapes test premask

clearvars -except templatesdir srcpath outdir srcvol count

thr = [1,1;3,4;5,5;5.2,5.2;5.4,5.4;5.6,5.6;5.8,5.8;7,8;9,10;11,12];

premasknames = {fullfile(templatesdir,'premask-sphere_lhpc_radius_08_center_x58y57z27.nii.gz');...
                fullfile(templatesdir,'premask-sphere_rhpc_radius_08_center_x33y57z27.nii.gz');...
                fullfile(templatesdir,'premask-sphere_tetra_radius_09_center_x47y61z56.nii.gz');...
                fullfile(templatesdir,'premask-sphere_cone_radius_15_center_x46y84z58.nii.gz')};

premaskcell = cell(4,1);
for n = 1:length(premasknames)
    vpre = spm_vol(premasknames{n});
    premaskcell{n} = spm_data_read(vpre);
end
preidx = [1,2,3,3,3,3,3,4,4,4];

grwmode = {'ascending';'descending';'similarity'};
nvox = inf;

for i = 1:length(grwmode)
    for j = 1:size(thr,1)
        count = count + 1;
        disp(['Creating ROI ',grwmode{i},' ',num2str(count)]);

        premask = premaskcell{preidx(j)};

        pmname = premasknames{preidx(j)}(...
            (strfind(premasknames{preidx(j)},'premask-sphere_')+length('premask-sphere_')):...
            (strfind(premasknames{preidx(j)},'_radius')-1));

        roipos = find(srcvol.*premask>=thr(j,1) & srcvol.*premask<=thr(j,2));
        sidx = randperm(length(roipos),1);
        [x,y,z] = ind2sub(size(srcvol),roipos(sidx));
        seed = [x,y,z];

        diffratio = abs(diff(thr(j,:)));
        if diffratio == 0
            diffratio = 0.001;
        end

        seedstr = num2str(sub2ind(size(srcvol),seed(1),seed(2),seed(3)));
        fname = fullfile(outdir,['fmroi-regiongrowing',...
            '_srcimg_syndata',...
            '_seed_',seedstr,...
            '_diffratio_',num2str(diffratio),...
            '_grwmode_',grwmode{i},...
            '_nvox_',num2str(nvox),...
            '_premask_',pmname,'.nii']);

        [~] = regiongrowingmask(srcpath,seed,diffratio,...
                                grwmode{i},nvox,premask,fname);
    end
end