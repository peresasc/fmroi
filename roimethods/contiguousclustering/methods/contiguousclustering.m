function mask = contiguousclustering(srcvol,minthrs,maxthrs,mincltsz)
% contiguousclustering group contiguous volxels (if their faces touch).
% If minthrs is lower than maxthrs, contiguousclustering consider as input
% those voxels that have values that are lower than minthrs and bigger than
% maxthrs. Otherwise, if minthrs is bigger than maxthrs, it considers those 
% voxels that have values lower than minthrs and bigger that maxthrs. All
% clusters that have less elements than mincltsz are eliminated.
%
% Syntax:
%   mask = contiguousclustering(data,minthrs,maxthrs,mincltsz)
% 
% Inputs:
%     srcvol: 3D matrix, usually a data volume from a nifti file.
%    minthrs: Scalar - Minimum threshold intensity. 
%    maxthrs: Scalar - Maximum threshold intensity.
%   mincltsz: Scalar - Minimum cluster size, clusters that have less
%             elements than mincltsz are eliminated.
%
% Output: 
%       mask: Integer 3D matrix with the same size as srcvol. The non-zero
%             values of mask are the indexes of each clusters.
% 
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

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