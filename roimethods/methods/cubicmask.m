function mask = cubicmask(vol,curpos,nvoxels,mode)
% cubicmask creates a cubic mask centered on curpos with the same
% dimension as srcvol with edge/volume equal to nvoxels. The mask is a
% binary array where the elements that belong to the cubic mask are set to
% 1 and all other voxels are set to 0.
% 
% Syntax:
%   mask = cubicmask(vol,curpos,nvoxel,mode)
% 
% Inputs:
%    srcvol: 3D matrix, usually a data volume from a nifti file.
%    curpos: Position where the cubic mask will be centered.
%   nvoxels: Edge or Volume size in voxels.
%      mode: String with the keywords 'edge' or 'volume' that defines if
%            nvoxels is the number of voxels that compose the ROI (volume)
%            or the edge size (edge).
%
% Output: 
%     mask: Binary 3D matrix with the same size as srcvol.
% 
%  Author: Andre Peres, 2019, peres.asc@gmail.com
%  Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

if ~exist('intype','var')
    mode = 'edge';
end

if strcmpi(mode,'edge')
    
    mask = makemask(vol, curpos, nvoxels);
    
elseif strcmpi(mode,'volume')
    
    r = ceil((3/(4*pi())*nvoxels)^(1/3));
    
    mask = makemask(vol, curpos, r);
    
    s = length(find(mask));
    
    if s<nvoxels
        mask = makemask(vol, curpos, r+1);
    end
    
    [x,y,z] = find3d(mask);
    ind = find(mask);
    
    d(:) = sqrt((x(:) - curpos(1)).^2 + (y(:) - curpos(2)).^2 + (z(:) - curpos(3)).^2);
    
    ss = length(d);
    remvox = ss-nvoxels;
    
    if remvox
        [~, maxind] = maxk(d,remvox);
        mask(ind(maxind)) = 0;
    end
    
else
    error('Undefined input type: type input should be edge or volume')
end

function mask = makemask(matrix, center, n)

mask = zeros(size(matrix));
auxmask = mask;
for i = 1:size(center,1)
    if rem(n(i),2)
        
        [mx,my,mz] = ndgrid(center(i,1)-floor(n(i)/2):center(i,1)+floor(n(i)/2),...
                            center(i,2)-floor(n(i)/2):center(i,2)+floor(n(i)/2),...
                            center(i,3)-floor(n(i)/2):center(i,3)+floor(n(i)/2));
                        
        auxmask([mx(:),my(:),mz(:)]) = 1;
        mask = mask|auxmask;
    else
        [mx,my,mz] = ndgrid(center(i,1)-floor(n(i)/2)+1:center(i,1)+floor(n(i)/2),...
                            center(i,2)-floor(n(i)/2)+1:center(i,2)+floor(n(i)/2),...
                            center(i,3)-floor(n(i)/2)+1:center(i,3)+floor(n(i)/2));
                        
        ind = sub2ind(size(mask),mx(:),my(:),mz(:));
        auxmask(ind) = 1;
        mask = mask|auxmask;
    end

end