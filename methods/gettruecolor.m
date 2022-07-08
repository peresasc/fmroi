function ctrue = gettruecolor(img2d,img3d,cmap)
% gettruecolor trasnforms the slice mxn to be displayed into a rgb matrix
% mxnx3 according to the colormap cmap.
%
% Syntax:
%   ctrue = gettruecolor(img2d,img3d,cmap)
%
% Inputs:
%   img2d: Slice mxn to be displayed.
%   img3d: Volume mxnxs from where img2d were extracted.
%    cmap: Selected colormap.
%
% Outputs:
%   ctrue: mxnx3 RGB matrix.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

if nargin == 0
    error('Not enougth input arguments')
end

if exist('img3d','var') && ~isempty(img3d)
    cmin = min(img3d(:));
    cmax = max(img3d(:));
else
    cmin = min(img2d(:));
    cmax = max(img2d(:));
end

s = size(cmap,1);

cind = round(((img2d-cmin)/(cmax-cmin))*(s-1))+1;
cind(isnan(cind)) = 1;
cind(cind<1) = 1;
cind(cind>s) = s;

c1 = zeros(size(img2d));
c2 = zeros(size(img2d));
c3 = zeros(size(img2d));

c1(:) = cmap(cind(:),1);
c2(:) = cmap(cind(:),2);
c3(:) = cmap(cind(:),3);

ctrue = cat(3,c1,c2,c3);