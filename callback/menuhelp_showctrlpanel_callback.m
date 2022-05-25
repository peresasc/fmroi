function menuhelp_showctrlpanel_callback(hObject,~)
% menuhelp_showctrlpanel_callback is an internal function of fMROI.
%
% Syntax:
%   menuhelp_showctrlpanel_callback(hObject,~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

handles = guidata(hObject);

set(handles.panel_control,'Visible','on');