function radiobutton_maskimage_callback(hObject, ~)
% radiobutton_maskimage_callback is an internal function of fMROI.
%
% Syntax:
%   radiobutton_maskimage_callback(hObject, ~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

handles = guidata(hObject);

set(handles.edit_roiradius,'Visible', 'off')
set(handles.text_roiradius,'Visible', 'off')
set(handles.text_maskimg,'Visible', 'on')
set(handles.popup_maskimg,'Visible', 'on')

guidata(hObject, handles);