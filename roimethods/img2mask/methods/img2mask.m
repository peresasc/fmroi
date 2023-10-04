function mask = img2mask(srcvol,minthrs,maxthrs,varargin)
% img2mask creates a mask determined by the minthrs and maxthrs intensity
% thresholds. If minthrs is lower than maxthrs, img2mask set to zero those
% voxels that have values that are lower than minthrs and bigger than
% maxthrs, i.e., mask = srcvol >= minthrs & srcvol <= maxthrs.
% Otherwise, if minthrs is bigger than maxthrs, img2mask set to zero those 
% voxels that have values lower than minthrs and bigger that maxthrs, i.e.,
% mask = srcvol >= minthrs | srcvol <= maxthrs;
%
% Syntax:
%   mask = img2mask(srcvol,minthrs,maxthrs)
% 
% Inputs:
%    srcvol: srcvol: 3D matrix or NIfTI file path used as the ROI template.
%   minthrs: Scalar - Minimum threshold intensity. 
%   maxthrs: Scalar - Maximum threshold intensity.
%
% Output: 
%      mask: Binary 3D matrix with the same size as srcvol.
% 
%  Author: Andre Peres, 2019, peres.asc@gmail.com
%  Last update: Andre Peres, 04/10/2023, peres.asc@gmail.com


if ischar(srcvol)
    srcpath = srcvol;
    v = spm_vol(srcvol);
    auxdata = spm_data_read(v);
    
    clear srcvol
    srcvol = auxdata;
end

if minthrs <= maxthrs
    z = srcvol >= minthrs & srcvol <= maxthrs; 
else                                    
    z = srcvol >= minthrs | srcvol <= maxthrs;
end

mask = zeros(size(srcvol));
mask(z) = 1;

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