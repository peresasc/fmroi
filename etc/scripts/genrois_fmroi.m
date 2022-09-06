%% gen_dmn_gaussnoise

tpldir = '/home/andre/github/tmp/fmroi_qc/dataset/templates';
if ~isfolder(tpldir)
    mkdir(tpldir)
end

vsrc = spm_vol('/home/andre/github/tmp/fmroi_qc/dataset/templates/default_mode_association-test_z_FDR_0.01.nii.gz');
srcvol = spm_data_read(vsrc);
as = mean(srcvol(srcvol>0));
an = as/sqrt(5);
gnoise = an*randn(1,numel(srcvol));
gnoise = reshape(gnoise,size(srcvol));
srcvol = srcvol + gnoise;

vsrc.fname = fullfile(tpldir,'default_mode_association-test_z_FDR_0.01_gaussnoise_5db.nii');
V = spm_create_vol(vsrc);
V.pinfo = [1;0;0]; % avoid SPM to rescale the masks
V = spm_write_vol(V,srcvol);

%% spheremask
outdir = '/home/andre/github/tmp/fmroi_qc/dataset/fmroi-spheremask';
if ~isfolder(outdir)
    mkdir(outdir)
end

vsrc = spm_vol('/home/andre/github/tmp/fmroi_qc/dataset/templates/T1.nii.gz');
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

vsrc = spm_vol('/home/andre/github/tmp/fmroi_qc/dataset/templates/T1.nii.gz');
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

vsrc = spm_vol('/home/andre/github/tmp/fmroi_qc/dataset/templates/syntheticdata.nii');
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

vsrc = spm_vol('/home/andre/github/tmp/fmroi_qc/dataset/templates/default_mode_association-test_z_FDR_0.01.nii.gz');
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

vsrc = spm_vol('/home/andre/github/tmp/fmroi_qc/dataset/templates/syntheticdata.nii');
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

%% maxkmask

outdir = '/home/andre/github/tmp/fmroi_qc/dataset/fmroi-maxkmask';
if ~isfolder(outdir)
    mkdir(outdir)
end

vsrc = spm_vol('/home/andre/github/tmp/fmroi_qc/dataset/templates/default_mode_association-test_z_FDR_0.01_gaussnoise_5db.nii');
srcvol = spm_data_read(vsrc);

vpre = spm_vol('/home/andre/github/tmp/fmroi_qc/dataset/templates/aparc+aseg_2mm.nii.gz');
prevol = spm_data_read(vpre);

pmidx = unique(prevol(:));
pmidx(pmidx==0) = [];

for i = 1:length(pmidx)
    disp(['Creating ROI ',num2str(i)]);

    premask = prevol==pmidx(i);
    kvox = randperm(sum(premask(:)),1);
    roi = maxkmask(srcvol,premask,kvox);

    vsrc.fname = fullfile(outdir,['fmroi-maxkmask_premaskidx_',...
        sprintf('%04d',pmidx(i)),'_kvox_',sprintf('%01d',kvox),'.nii']);

    V = spm_create_vol(vsrc);
    V.pinfo = [1;0;0]; % avoid SPM to rescale the masks
    V = spm_write_vol(V,roi);
end

%% regiongrowing

outdir = '/home/andre/github/tmp/fmroi_qc/dataset/fmroi-regiongrowing';
if ~isfolder(outdir)
    mkdir(outdir)
end

vsrc = spm_vol('/home/andre/github/tmp/fmroi_qc/dataset/templates/syntheticdata.nii');
srcvol = spm_data_read(vsrc);

% s1 = readtable(fullfile(srcdir,'external_spiral.csv'));
% s2 = readtable(fullfile(srcdir,'internal_spiral.csv'));

% tpl = {lhpc;rhpc;th1;th2;th3;th4;th5;intspr;cone;extspr};
% 
% thr = [1,1;3,4;5,5;5.2,5.2;5.4,5.4;5.6,5.6;5.8,5.8;7,8;9,10;11,12];
% mask = regiongrowingmask(srcvol, seed, diffratio, grwmode, nvox, premask)

%--------------------------------------------------------------------------
% spirals test
seed = [46,84,50;46,84,50;46,84,50;46,84,49];
diffratio = inf;
grwmode = {'ascending';'descending';'similarity';'similarity'};
nvox = {round(linspace(31,221,20));...
        round(linspace(21,116,20));...
        round(linspace(23,221,10));...
        round(linspace(16,115,10))};

premask = srcvol;

for i = 1:length(grwmode)
    count = 0;
    for j = 1:length(nvox{i})
        if i==4 && j==1
            count = 11;
        else
            count = count+1;
        end

        disp(['Creating ROI ',grwmode{i},' ',num2str(count)]);
     
        roi = regiongrowingmask(srcvol,seed(i,:),diffratio,...
                                grwmode{i},nvox{i}(j),premask);
        
        seedstr = num2str(sub2ind(size(srcvol),seed(i,1),seed(i,2),seed(i,3)));
        vsrc.fname = fullfile(outdir,['fmroi-regiongrowing',...
            '_seed_',seedstr,...
            '_diffratio_',num2str(diffratio),...
            '_grwmode_',grwmode{i},...
            '_nvox_',num2str(nvox{i}(j)),...
            '_premask_srcvol.nii']);            

        V = spm_create_vol(vsrc);
        V.pinfo = [1;0;0]; % avoid SPM to rescale the masks
        V = spm_write_vol(V,roi);
    end
end

%--------------------------------------------------------------------------
% shapes test
clear seed diffratio grwmode nvox premask

thr = [1,1;3,4;5,5;5.2,5.2;5.4,5.4;5.6,5.6;5.8,5.8;7,8;9,10;11,12];
grwmode = {'ascending';'descending';'similarity'};
nvox = inf;
premask = srcvol;

count = 0;
for i = 1:length(grwmode)
    for j = 1:size(thr,1)
        count = count + 1;
        disp(['Creating ROI ',grwmode{i},' ',num2str(count)]);

        roipos = find(srcvol>=thr(j,1) & srcvol<=thr(j,2));

        diffratio = abs(diff(thr(j,:)));
        if diffratio == 0
            diffratio = 0.001;
        end
        sidx = randperm(length(roipos),1);
        [x,y,z] = ind2sub(size(srcvol),roipos(sidx));
        seed = [x,y,z];

        roi = regiongrowingmask(srcvol,seed,diffratio,...
                                grwmode{i},nvox,premask);

        seedstr = num2str(sub2ind(size(srcvol),seed(1),seed(2),seed(3)));
        vsrc.fname = fullfile(outdir,['fmroi-regiongrowing',...
            '_seed_',seedstr,...
            '_diffratio_',num2str(diffratio),...
            '_grwmode_',grwmode{i},...
            '_nvox_',num2str(nvox),...
            '_premask_srcvol.nii']);            

        V = spm_create_vol(vsrc);
        V.pinfo = [1;0;0]; % avoid SPM to rescale the masks
        V = spm_write_vol(V,roi);
    end
end