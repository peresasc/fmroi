% % gen_complex-shapes
% Left Hypocampus: 1
%   All voxels are equal to 1.
%
% Right Hypocampus: 3 - 4
%   3-3.9 - random distributed: whole ROI.
%   3.91-4 - linear distributed: 50 random selected voxels.
% 
% tetrahedron: 5 - 6
%   central region = 5
%   superior-anterior corner = 5.2
%   superior-posterior corner = 5.4
%   inferior-left corner = 5.6
%   inferior-right corner = 5.8
% 
% internal spiral: 7 - 8
%   7-7.8 linear distributed: spiral from base to top
%   7.8-8 linear distributed: linking bar from internal to external spiral
%
% cone: 9 - 10
%   9-10 - random distributed: whole ROI.
% 
% external spiral: 11 - 12
%   11-12 linear distributed: from top to base.


fmroirootdir = '/home/andre/github/fmroi';
outdir = '/home/andre/github/tmp/syndata';
addpath(fullfile(fmroirootdir,'etc','scripts','Mesh_voxelisation','Mesh_voxelisation'));


srcvol = fullfile(fmroirootdir,'etc','default_templates',...
    'FreeSurfer','cvs_avg35_inMNI152','aparc+aseg_2mm.nii.gz');
fsidx = [17,53];

v = spm_vol(srcvol);
data = spm_data_read(v);
mask = zeros(size(data));

%----------------------------------------------------------------------
% generate the Left Hypocampus
mask(data == fsidx(1)) = 1;

%----------------------------------------------------------------------
% generate the Right Hypocampus
rhidx = find(data == fsidx(2));
mask(rhidx) = 3 + 0.9*rand(1,length(rhidx));
rpidx = rhidx(randperm(length(rhidx),50));
mask(rpidx) = linspace(3.91,4,50);
[rmax50,cmax50,smax50] = ind2sub(size(mask),rpidx);
writematrix([rmax50,cmax50,smax50],fullfile(outdir,'rh-hyp_max50.csv'));

%----------------------------------------------------------------------
% generate the tetrahedron
vt = [1,0,-(2)^(-.5);-1,0,-(2)^(-.5);0,1,(2)^(-.5);0,-1,(2)^(-.5)];
lk = 1:4;

figure
h = tetramesh(lk,vt);

g = 20;
tvol = VOXELISE(g,g,g,h);

[r,c,s] = find3d(tvol);
ttidx = sub2ind(size(mask),r+36,c+50,s+45);

mask(ttidx) = 5;

valit = [5.2,5.4,5.6,5.8];
sphcenter = [47 70 65;47 52 65;56 61 47;38 61 47];
data = cell(2,1);
data{1} = mask;
op{1} = 'AND';
for i = 1:size(sphcenter,1)
data{2} = spheremask(mask,sphcenter(i,:),8,'radius');
it = logic_chain(data,op);
mask(it) = valit(i);
end

%----------------------------------------------------------------------
% generate the cone
[X,Y,Z] = cylinder([1 0],1000);

h = surf(X,Y,Z,'LineStyle','none','FaceAlpha',0.3);
fvc = surf2patch(h);
cvol = VOXELISE(40,40,30,fvc);

[r,c,s] = find3d(cvol);
cnidx = sub2ind(size(mask),r+25,c+63,s+28);

mask(cnidx) = 9 + rand(1,length(cnidx));

%----------------------------------------------------------------------
% generate the spiral1
origpos = [0,0,20;-15,7,0] ;  % startpos;endpos
startpos = [46,84,30];

pos = origpos + [startpos;startpos];
nturns = 3;    % number of turns (integer value)

res = 100000;

dp = diff(pos,1,1);
R = hypot(dp(1),dp(2));
phi0 = atan2(dp(2),dp(1));
phi = linspace(0,nturns*2*pi,res);
r = linspace(0,R,numel(phi));
vt = pos(1,1) + r .* cos(phi+phi0);
y = pos(1,2) + r .* sin(phi+phi0);
z = linspace(pos(1,3),pos(2,3),res);

s1 = unique(round([vt',y',z']),'stable','rows');
s1val = linspace(12,11,length(s1));

idxs1 = sub2ind(size(mask),s1(:,1),s1(:,2),s1(:,3));
mask(idxs1) = s1val;
writematrix([idxs1,s1val'],fullfile(outdir,'external_spiral.csv'));

%----------------------------------------------------------------------
% generate the spiral2
origpos = [0,0,0;-8,7,10] ;  % startpos;endpos
startpos = [46,84,30];

pos = origpos + [startpos;startpos];
nturns = 2; % number of turns (integer value)

res = 100000;

dp = diff(pos,1,1);
R = hypot(dp(1),dp(2));
phi0 = atan2(dp(2),dp(1));
phi = linspace(nturns*2*pi,0,res);
r = linspace(0,R,numel(phi));
vt = pos(1,1) + r .* cos(phi+phi0);
y = pos(1,2) + r .* sin(phi+phi0);
z = linspace(pos(1,3),pos(2,3),res);

s2 = unique(round([vt',y',z']),'stable','rows');

s3 = zeros(20,3); % external to internal linking bar
for i = 1:20
    s3(i,:) = [46, 84, 50-i];
end

s2 = [s3;s2];
s2 = unique(s2,'stable','rows');

s2val = linspace(7,8,length(s2));

idxs2 = sub2ind(size(mask),s2(:,1),s2(:,2),s2(:,3));
mask(idxs2) = s2val;

s1del = ismember(idxs1,idxs2);
idxs1(s1del) = [];
s1val(s1del) = [];
s1tb = table(idxs1,s1val,'VariableNames',{'index','values'});
writetable(s1tb,fullfile(outdir,'external_spiral.csv'));

s2tb = table(idxs2,s2val,'VariableNames',{'index','values'});
writetable(s2tb,fullfile(outdir,'internal_spiral.csv'));

% figure
% plot3(s1(:,1),s1(:,2),s1(:,3))
% hold on
% plot3(s2(:,1),s2(:,2),s2(:,3))


filename = fullfile(outdir,'complex-shapes.nii');
v.fname = filename;
v = spm_create_vol(v);
v.pinfo = [1;0;0]; % avoid SPM to rescale the masks
v = spm_write_vol(v,mask);

%
idxs1 = s1(:,1);
s1val = s1(:,2);
s1tb = table(idxs1,s1val,'VariableNames',{'index','values'});
writetable(s1tb,fullfile(outdir,'external_spiral.csv'));

idxs2 = s2(:,1);
s2val = s2(:,2);
s2tb = table(idxs2,s2val,'VariableNames',{'index','values'});
writetable(s2tb,fullfile(outdir,'internal_spiral.csv'));

%% gen_dmn_gaussnoise
clear
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

%% gen_premasks_syndata
clear
tpldir = '/home/andre/github/tmp/fmroi_qc/dataset/templates';
if ~isfolder(tpldir)
    mkdir(tpldir)
end

vsrc = spm_vol('/home/andre/github/tmp/fmroi_qc/dataset/templates/syntheticdata.nii');
srcvol = spm_data_read(vsrc);

radius = [8,8,9,15];
center = [58,57,27;...
          33,57,27;...
          47,61,56;...
          46,84,58];

masknames = {'premask-sphere_lhpc';...
             'premask-sphere_rhpc';...
             'premask-sphere_tetra';...
             'premask-sphere_cone'};

for i = 1:length(radius)

    roi = spheremask(srcvol,center(i,:),radius(i),'radius');

    vsrc.fname = fullfile(tpldir,[masknames{i},...
        '_radius_',sprintf('%02d',radius(i)),...
        '_center_x',sprintf('%02d',center(i,1)),...
        'y',sprintf('%02d',center(i,2)),...
        'z',sprintf('%02d',center(i,3)),'.nii']);

    V = spm_create_vol(vsrc);
    V.pinfo = [1;0;0]; % avoid SPM to rescale the masks
    V = spm_write_vol(V,roi);
end

%% gen_spheres
clear
tpldir = '/home/andre/github/tmp/fmroi_qc/dataset/templates';
if ~isfolder(tpldir)
    mkdir(tpldir)
end

vsrc = spm_vol('/home/andre/github/tmp/fmroi_qc/dataset/templates/syntheticdata.nii');
srcvol = spm_data_read(vsrc);


roi = zeros(size(srcvol));
roisz = zeros(size(srcvol));
count = 0;
for i = 13:22:79
    for j = 13:22:79
        for k = 13:22:79
            count = count + 1;
            auxroi = spheremask(srcvol,[i,j,k],randperm(10,1),'radius');
            n = numel(find(auxroi(:)));

            roi = roi + count*auxroi;
            roisz = roisz + n*auxroi;
        end
    end
end

vsrc.fname = fullfile(tpldir,'spheres.nii');
V = spm_create_vol(vsrc);
V.pinfo = [1;0;0]; % avoid SPM to rescale the masks
V = spm_write_vol(V,roi);

vsrc.fname = fullfile(tpldir,'spheres_size.nii');
V = spm_create_vol(vsrc);
V.pinfo = [1;0;0]; % avoid SPM to rescale the masks
V = spm_write_vol(V,roisz);
