function slices = getslices(st,n_image)
% getslices is a internal function of fMROI that extracts the slices to
% display from the images volume.
%
% Syntax:
%   slices = getslices(st,n_image)
%
% Inputs:
%        st: Structure array that carries the information about the images.
%            It is based on the st structure from SPM.
%   n_image: Number of loaded images.
%
% Outputs:
%    slices: 3x1 cell array containing the axial, coronal and sagittal
%            respectively to be displayed.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com


%==========================================================================
% function redraw(st)
%==========================================================================
if ~exist('n_image','var')
    n_image = 1;
end

if isempty(n_image)
    n_image = 1;
end


bb   = st.bb;
Dims = round(diff(bb)'+1);
is   = inv(st.Space);
cent = is(1:3,1:3)*st.centre(:) + is(1:3,4);

i = n_image;

M = st.Space\st.vols{i}.premul*st.vols{i}.mat;

% Transversal/Axial affine transformation
TM0 = [ 1 0 0 -bb(1,1)+1
        0 1 0 -bb(1,2)+1
        0 0 1 -cent(3)
        0 0 0 1];

TM = inv(TM0*M);
TD = Dims([1 2]);

% Coronal affine transformation
CM0 = [ 1 0 0 -bb(1,1)+1
        0 0 1 -bb(1,3)+1
        0 1 0 -cent(2)
        0 0 0 1];
    
CM = inv(CM0*M);
CD = Dims([1 3]);

% Sagital affine transformation
if st.mode == 0
    SM0 = [ 0 0 1 -bb(1,3)+1
            0 1 0 -bb(1,2)+1
            1 0 0 -cent(1)
            0 0 0 1];
        
    SM = inv(SM0*M);
    SD = Dims([3 2]);
else
    SM0 = [ 0 -1 0 +bb(2,2)+1
            0  0 1 -bb(1,3)+1
            1  0 0 -cent(1)
            0  0 0 1];
        
    SM = inv(SM0*M);
    SD = Dims([2 3]);
end

try
    imgt = spm_slice_vol(st.vols{i},TM,TD,st.hld)';
    imgc = spm_slice_vol(st.vols{i},CM,CD,st.hld)';
    imgs = spm_slice_vol(st.vols{i},SM,SD,st.hld)';
catch
    fprintf('Cannot access file "%s".\n', st.vols{i}.fname);
    fprintf('%s\n',getfield(lasterror,'message'));
end

slices = cell(3,1);
slices{1} = nan2num(imgt);
slices{2} = nan2num(imgc);
slices{3} = nan2num(imgs);


