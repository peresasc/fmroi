function mask = maxkmask(srcvol,premask,kvox)
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

roi_idx = find(premask);
vetroi = srcvol(roi_idx);
[~, kidx] = maxk(vetroi(:),kvox);
k = roi_idx(kidx);
mask = zeros(size(srcvol));
mask(k) = 1;