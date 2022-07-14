function mask = regiongrowingmask_caller(hObject,srcvol,curpos)
% regiongrowingmask_caller is an internal function of fMROI. It calls the 
% regiongrowingmask function.
% 
% Syntax:
%   mask = regiongrowingmask_caller(hObject,srcvol,curpos)
% 
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.handles.buttongroup_growingpremask
%    srcvol: 3D matrix, usually a data volume from a nifti file.
%    curpos: Position where the sphere mask will be centered.
%
% Output: 
%      mask: Binary 3D matrix with the same size as srcvol. 
% 
%  Author: Andre Peres, 2019, peres.asc@gmail.com
%  Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

handles = guidata(hObject);

premaskmth = lower(...
    handles.buttongroup_growingpremask.SelectedObject.String);

switch premaskmth
    case 'mask'
        premask = img2mask_caller(hObject,'premask');
        handles = guidata(hObject);

    case 'sphere'
        radius = str2double(get(...
            handles.edit_growingpremasradius,'String'));
        premask = spheremask(srcvol, curpos, radius, 'radius');

    case 'none'
        premask = ones(size(srcvol));
        
    otherwise
        error('Undefined method type: the method should be sphere or image')
end

ngrwmode = get(handles.popup_growingmode,'Value');
s = get(handles.popup_growingmode,'String');
grwmode = s{ngrwmode};

diffratio = str2double(get(handles.edit_growingthrsmeth,'String'));

nvox = str2double(get(handles.edit_roinvox,'String'));           
mask = regiongrowingmask(srcvol, curpos, diffratio, grwmode, nvox, premask);