function mask = spheremask_caller(hObject,srcvol,curpos)
% spheremask_caller is an internal function of fMROI. It calls the 
% spheremask function for creating spherical masks.
% 
% Syntax:
%   mask = spheremask_caller(hObject,srcvol,curpos)
% 
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%    srcvol: 3D matrix, usually a data volume from a nifti file.
%    curpos: Position where the sphere mask will be centered.
%
% Output: 
%      mask: Binary 3D matrix with the same size as srcvol. 
% 
%  Author: Andre Peres, 2019, peres.asc@gmail.com
%  Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

handles = guidata(hObject);

method = handles.buttongroup_spheremasktype.SelectedObject.String;
nvoxels = str2double(get(handles.edit_roiradius,'String'));

mask = spheremask(srcvol,curpos,nvoxels,method);

guidata(hObject,handles);