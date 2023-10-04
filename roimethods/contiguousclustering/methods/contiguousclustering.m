function mask = contiguousclustering(srcvol,minthrs,maxthrs,mincltsz,varargin)
% contiguousclustering group contiguous volxels (if their faces touch).
% If minthrs is lower than maxthrs, contiguousclustering consider as input
% those voxels that have values that are lower than minthrs and bigger than
% maxthrs. Otherwise, if minthrs is bigger than maxthrs, it considers those 
% voxels that have values lower than minthrs and bigger that maxthrs. All
% clusters that have less elements than mincltsz are eliminated.
%
% Syntax:
%   mask = contiguousclustering(data,minthrs,maxthrs,mincltsz,varargin)
% 
% Inputs:
%     srcvol: srcvol: 3D matrix or NIfTI file path used as the ROI
%             template.
%    minthrs: Scalar - Minimum threshold intensity. 
%    maxthrs: Scalar - Maximum threshold intensity.
%   mincltsz: Scalar - Minimum cluster size, clusters that have less
%             elements than mincltsz are eliminated.
%   varargin: Output file path for ROIs in NIfTI format. If a different
%             extension is entered, it will be automatically set to .nii.
%             Set this parameter only for NIfTI file saving.
%
% Output: 
%       mask: Integer 3D matrix with the same size as srcvol. The non-zero
%             values of mask are the indexes of each clusters.
% 
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 04/10/2023, peres.asc@gmail.com

if ischar(srcvol)
    srcpath = srcvol;
    v = spm_vol(srcvol);
    auxdata = spm_data_read(v);
    
    clear srcvol
    srcvol = auxdata;
end

bwimg = img2mask(srcvol,minthrs,maxthrs);
mask = zeros(size(bwimg));
auxclt = bwconncomp(bwimg,6);
clt = auxclt.PixelIdxList;

count = 0;
for i = 1:length(clt)
    if length(clt{i}) >= mincltsz
        count = count +1;
        mask(clt{i}) = count;
    end
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