function [rows,columns,slices] = find3d(matrix3d)
% find3d find indices of nonzero elements in 3D matrices and returns 
% the rows, columns and slices index.
%
% Syntax:
%   [rows,columns,slices] = find3d(matrix3d)
%
% Inputs:
%   matrix3d: 3D matrix
%
% Outputs:
%      rows: row indexes.
%   columns: columns indexes.
%    slices: slice indexes.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

[rows,columns,slices] = ind2sub(size(matrix3d),find(matrix3d));