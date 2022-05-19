function [cmap,idx] = selectlutcolormap(srcidx,lutidx,origcmap)
% selectlutcolormap searches for the srcidx indices in the color LUT
% indices (lutidx) and returns only those origcolormap RGB values 
% associated with srcidx.
%
% Syntax:
%   [cmap,idx] = selectlutcolormap(srcidx,lutidx,origcmap)
%
% Inputs:
%     srcidx: mx1 vector containing the srcidx indexes.
%     lutidx: nx1 vector containing the color LUT indexes.
%   origcmap: nx3 RGB colormap matrix with values between 0 to 1.
%
% Outputs:
%       cmap: kx3 RGB colormap matrix with values between 0 to 1, where k
%             is the maximum value of srcidx plus 1: k = max(srcidx)+1.
%        idx: kx1 vector containing the srcidx indexes (0:max(srcidx)).
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

idx = (0:max(srcidx))';
cmap = zeros(max(srcidx)+1,3);
for j = 0:max(srcidx)
    a = find(lutidx==j,1);
    if ~isempty(a)
        cmap(j+1,:) = [origcmap(a,1),origcmap(a,2),origcmap(a,3)];
    end
end