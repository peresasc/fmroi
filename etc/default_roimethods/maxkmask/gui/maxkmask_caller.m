function mask = maxkmask_caller(hObject,srcvol,curpos)
% maxkmask_caller is an internal function of fMROI. It calls the 
% maxkmask function.
% 
% Syntax:
%   mask = maxkmask_caller(hObject,srcvol,curpos)
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
method = lower(handles.buttongroup_spheremasktype.SelectedObject.String);


if strcmpi(method,'sphere')
    radius = str2double(get(handles.edit_roiradius,'String'));
    premask = spheremask(srcvol, curpos, radius, 'radius');    
elseif strcmpi(method,'mask image')
    premask = img2mask_caller(hObject,'premask');
    handles = guidata(hObject);
else
    error('Undefined method type: the method should be sphere or image')
end

k = str2double(get(handles.edit_roinvox,'String'));

mask = maxkmask(srcvol,premask,k);