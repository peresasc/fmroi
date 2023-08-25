function menuconfig_restoretools(hObject,~)
% menuconfig_restoretools is an internal function of fMROI.
%
% Syntax:
%   menuconfig_restoretools(hObject,~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2023, peres.asc@gmail.com
% Last update: Andre Peres, 25/08/2023, peres.asc@gmail.com

handles = guidata(hObject);
if exist(handles.toolsdir,'dir')
    rmdir(handles.toolsdir,'s')
end

copyfile(fullfile(handles.fmroirootdir,'etc','default_tools'),...
    handles.toolsdir);

p = genpath(handles.toolsdir);
addpath(p);

% Update the popup_roitype
guidata(hObject,handles);
updatemenutools(hObject);
