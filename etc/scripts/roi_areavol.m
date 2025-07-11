function [area,vol,inneredge,outeredge] = roi_areavol(data)
% roi_areavol computes the surface area and volume of a 3D binary ROI mask.
% It also returns the inner and outer edge voxels that define the ROI boundary.
% The surface area is estimated by counting the number of exposed voxel faces.
%
% Syntax:
%   [area,vol,inneredge,outeredge] = roi_areavol(data)
%
% Input:
%    data: 3D binary matrix representing a mask, or path to a NIfTI file
%          containing a 3D binary mask. Voxels inside the ROI must be non-zero.
%
% Outputs:
%     area: Estimated surface area of the ROI, in number of exposed voxel faces.
%      vol: Volume of the ROI, in number of voxels.
% inneredge: 3D binary matrix marking voxels on the inner boundary of the ROI.
% outeredge: 3D binary matrix marking external voxels adjacent to the ROI surface.
%
%  Author: Andre Peres, 2023, peres.asc@gmail.com
%  Last update: Andre Peres, 11/07/2025, peres.asc@gmail.com

if ischar(data)
    v = spm_vol(data);
    auxdata = spm_data_read(v);
    
    clear data
    data = auxdata;
end

outeredge = zeros(size(data));
inneredge = zeros(size(data));
[x,y,z] = find3d(data);
vol = length(x);
area = 0;
for i = 1:vol
    for j = -1:1
        if x(i)+j>0 && x(i)+j<=size(data,1) % Test if the voxel is in the x limits
            if data(x(i)+j,y(i),z(i)) == 0
                area = area+1;
                outeredge(x(i)+j,y(i),z(i)) = 1;
                inneredge(x(i),y(i),z(i)) = 1;
            end
        end

        if y(i)+j>0 && y(i)+j<=size(data,2) % Test if the voxel is in the y limits
            if data(x(i),y(i)+j,z(i)) == 0
                area = area+1;
                outeredge(x(i),y(i)+j,z(i)) = 1;
                inneredge(x(i),y(i),z(i)) = 1;
            end
        end

        if z(i)+j>0 && z(i)+j<=size(data,3) % Test if the voxel is in the z limits
            if data(x(i),y(i),z(i)+j) == 0
                area = area+1;
                outeredge(x(i),y(i),z(i)+j) = 1;
                inneredge(x(i),y(i),z(i)) = 1;
            end
        end
    end
end