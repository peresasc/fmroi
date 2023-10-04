function mask = spheremask(srcvol,curpos,nvoxels,mode,varargin)
% spheremask creates a spherical mask centered on curpos with the same
% dimension as srcvol with radius/volume equal to nvoxels.The mask is a
% binary array where the elements that belong to the sphere mask are set to
% 1 and all other voxels are set to 0.
%
% Syntax:
%   mask = spheremask(srcvol,curpos,nvoxels,mode)
%
% Inputs:
%    srcvol: 3D matrix, usually a data volume from a nifti file.
%    curpos: Position where the sphere mask will be centered.
%   nvoxels: Radius or Volume size in voxels.
%      mode: String with the keywords 'radius' or 'volume' that defines if
%            nvoxels is the number of voxels that compose the ROI (volume)
%            or the radius size (radius).
%
% Output:
%     mask: Binary 3D matrix with the same size as srcvol.
%
%  Author: Andre Peres, 2019, peres.asc@gmail.com
%  Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

if ischar(srcvol)
    srcpath = srcvol;
    v = spm_vol(srcvol);
    auxdata = spm_data_read(v);

    clear srcvol
    srcvol = auxdata;
end

if ~exist('mode','var') || isempty(mode)
    mode = 'radius';
end

if strcmpi(mode,'radius')

    mask = makemask(srcvol,curpos,nvoxels);

elseif strcmpi(mode,'volume')

    r = ceil((3/(4*pi())*nvoxels)^(1/3));

    mask = makemask(srcvol,curpos,r);

    s = length(find(mask));

    if s<nvoxels
        mask = makemask(srcvol,curpos,r+1);
    end

    [x,y,z] = find3d(mask);
    ind = find(mask);
    % distance of every voxel in the ROI to the center
    d(:) = sqrt((x(:) - curpos(1)).^2 + (y(:) - curpos(2)).^2 + (z(:) - curpos(3)).^2);

    ss = length(d);
    remvox = ss-nvoxels; % number of voxels to be removed

    if remvox
        [~, maxind] = maxk(d,remvox); % find the remvox voxels most distant to the center
        mask(ind(maxind)) = 0; % remove the remvox voxels most distant to the center
    end

else
    error('Undefined input type: type input should be radius or volume')
end

%--------------------------------------------------------------------------
% Save mask to a nifti file
if ~isempty(varargin)
    [pn,fn,~] = fileparts(varargin{1});
    if ~isempty(pn) && ~exist(pn,'dir')
        mkdir(pn);
    end

    outpath = fullfile(pn,[fn,'.nii']);
    mask = uint16(mask);
    mat2nii(mask,srcpath,outpath)
end

function mask = makemask(matrix, center, n)

[x,y,z] = size(matrix);
mask = zeros(size(matrix));
for i = 1:size(center,1)

    [Mx,My,Mz]=ndgrid(1:x,1:y,1:z);
    auxmask = (sqrt((Mx - center(i,1)).^2 + (My - center(i,2)).^2 + (Mz - center(i,3)).^2)<=n(i));
    mask = mask|auxmask;
end