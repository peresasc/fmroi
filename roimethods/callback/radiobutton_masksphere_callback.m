function radiobutton_masksphere_callback(hObject, ~)
% radiobutton_masksphere_callback is an internal function of fMROI.
%
% Syntax:
%   radiobutton_masksphere_callback(hObject, ~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

handles = guidata(hObject);

set(handles.text_maskimg,'Visible', 'off')
set(handles.popup_maskimg,'Visible', 'off')
set(handles.edit_growingpremasradius,'Visible', 'on')
set(handles.text_growingpremasradius,'Visible', 'on')

guidata(hObject, handles);