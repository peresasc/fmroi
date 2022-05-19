function menuconfig_restoretpl_callback(hObject,~)
% menuconfig_restoretpl_callback is an internal function of fMROI.
%
% Syntax:
%   menuconfig_restoretpl_callback(hObject,~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

menuconfig_cleartpl_callback(hObject)

handles = guidata(hObject);
copyfile(fullfile(handles.fmroirootdir,'etc','default_templates'),...
    handles.tpldir);
guidata(hObject,handles);

% Update the templates submenus
updatemenutemplate(hObject);

