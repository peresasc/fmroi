function popup_growingthrsmeth_callback(hObject, ~)
% popup_growingthrsmeth_callback is an internal function of fMROI.
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
n = get(handles.popup_growingthrsmeth,'Value');

if n == 1
    set(handles.edit_growingthrsmeth,'Enable','off')
    set(handles.edit_growingthrsmeth,'String','inf')
else
    set(handles.edit_growingthrsmeth,'Enable', 'on')    
end