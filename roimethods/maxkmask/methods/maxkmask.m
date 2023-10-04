function mask = maxkmask(srcvol,premask,kvox,varargin)
% maxkmask searches for the kvox highest-intensity voxels of the srcvol
% contained in the region defined by premask. 
%
% Syntax:
%   mask = maxkmask(srcvol,premask,kvox)
% 
% Inputs:
%    srcvol: 3D matrix, usually a data volume from a nifti file.
%   premask: Binary 3D matrix with same size as srcvol. If premask is not
%            a binary matrix, maxkmask will consider as ROI all non-zero
%            elements.
%      kvox: Integer that defines the number of non-zero elements in mask.
%
% Output: 
%      mask: Binary 3D matrix with the same size as srcvol.
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

if ischar(premask)
    v = spm_vol(premask);
    auxpremask = spm_data_read(v);
    
    clear premask
    premask = auxpremask;
end

roi_idx = find(premask);
vetroi = srcvol(roi_idx);
[~, kidx] = maxk(vetroi(:),kvox);
k = roi_idx(kidx);
mask = zeros(size(srcvol));
mask(k) = 1;

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