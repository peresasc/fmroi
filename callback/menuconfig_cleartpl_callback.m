function menuconfig_cleartpl_callback(hObject,~)
% menuconfig_imptpl_callback is an internal function of fMROI.
%
% Syntax:
%   menuconfig_imptpl_callback(hObject,~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

handles = guidata(hObject);


if exist(handles.tpldir,'dir')
    rmdir(handles.tpldir, 's')
    mkdir(handles.tpldir);
end

% Update the templates submenus
guidata(hObject,handles);
updatemenutemplate(hObject);
