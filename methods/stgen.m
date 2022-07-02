function st = stgen(hObject, img_path, st)
% stgen is a internal function of fMROI that generate or update the st 
% structure.
%
% Syntax:
%   st = stgen(img_path, st)
%
% Inputs:
%         st: Structure array to be updated. It carries information about
%             the images and is based on SPM st structure.
%   img_path: String containing the path to the nifti file to be added in
%             the st structure.
%
% Outputs:
%         st: Updated structure array that carries the information about
%             the images. It is based on the st structure from SPM.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

if ~exist('img_path','var')
    error('Provide a nifti image path')
end

if ~exist('st','var')
    st = stgen0;
end

if isempty(st)
    st = stgen0;
end

handles = guidata(hObject);
nextcell = find(cellfun(@isempty,st.vols), 1);
i = nextcell;

%--------------------------------------------------------------------------

V = spm_vol(img_path);
if length(V) > 1
    hw = warndlg('fMROI does not suport 4D images!Only the first volume will be loaded.');
    uiwait(hw)

    outdir = handles.tmpdir;
    [~,fn,ext] = spm_fileparts(img_path);
    i = 1; % volume to be loaded
    outpath = fullfile(outdir ,sprintf('%s_%05d%s',fn,i,ext));
    ni = nifti;
    ni.dat = file_array(outpath,V(i).dim(1:3),V(i).dt,0,V(i).pinfo(1),V(i).pinfo(2));
    ni.mat = V(i).mat;
    ni.mat0 = V(i).mat;
    ni.mat_intent = V(i).private.mat_intent;
    ni.mat0_intent = V(i).private.mat0_intent;
    ni.descrip = [V(i).descrip sprintf(' - %d',i)];
    create(ni);
    ni.dat(:,:,:) = V(i).private.dat(:,:,:,i);

    clear V
    V = spm_vol(outpath);
end

V.ax = cell(3,1); %???
V.premul    = eye(4);
V.window    = 'auto';
V.mapping   = 'linear';
st.vols{i} = V;
H = 1;
st.vols{H}.area = [0 0 1 1];

%--------------------------------------------------------------------------
% Determines the bounding box for displaying the images. Only the first
% loaded imgage is considered to determine the display parameters. If the 
% subsequent loaded images have different resolution, they will be 
% transformed to the display resolution (st.Space) to be displayed.
if isempty(st.bb)
    
    mn = [Inf Inf Inf];
    mx = -mn;
    
    premul = st.Space \ st.vols{i}.premul; % A\B == inv(A)*B
    
    % SPM function to compute volume's bounding box for full field of view.
    bb = spm_get_bbox(st.vols{i}, 'fv', premul);
    
    mx = max([bb ; mx]);
    mn = min([bb ; mn]);
    
    st.bb = [mn ; mx];  
end

        
%--------------------------------------------------------------------------
% Determines de resolution to display the images

if ~isfield(st,'res')
    % Resolution is set to a isovoxel with edge size equal to the smallest
    % voxel dimension of the first loaded image.
    res = inf;
    res = min([res,sqrt(sum((st.vols{i}.mat(1:3,1:3)).^2))]);
    res = res/mean(svd(st.Space(1:3,1:3)));
    Mat = diag([res res res 1]);
    
    % Resolution of displayed images. If the images have different
    % resolution they will be transformed to st.Space to be displayed.
    st.Space = st.Space*Mat;
    
    % Transform st.bb from mm to voxel units, regarding the display voxel
    % resolution st.res.
    st.bb = st.bb/res;
    
    % Determines the mass center of the displayed image in refrence to the
    % scanner coordinates in mm and stores in the st.centre.
    centre_scanner = mean(st.Space*[st.bb';1 1],2)';
    st.centre = centre_scanner(1:3);
    st.res = res;
end

%--------------------------------------------------------------------------
% Function to gerenate the st variable
function st = stgen0


fig = spm_figure('FindWin','Graphics');
bb  = []; 
st  = struct('n', 0, 'vols',{cell(24,1)}, 'bb',bb, 'Space',eye(4), ...
             'centre',[0 0 0], 'callback',';', 'xhairs',1, 'hld',1, ...
             'fig',fig, 'mode',1, 'plugins',{{}}, 'snap',[]);

xTB = spm('TBs');
if ~isempty(xTB)
    pluginbase = {spm('Dir') xTB.dir};
else
    pluginbase = {spm('Dir')};
end
for k = 1:numel(pluginbase)
    pluginpath = fullfile(pluginbase{k},'spm_orthviews');
    if exist(pluginpath,'dir') == 7
        pluginfiles = dir(fullfile(pluginpath,'spm_ov_*.m'));
        if ~isempty(pluginfiles)
            if ~isdeployed, addpath(pluginpath); end
            for l = 1:numel(pluginfiles)
                pluginname = spm_file(pluginfiles(l).name,'basename');
                st.plugins{end+1} = strrep(pluginname, 'spm_ov_','');
            end
        end
    end
end

