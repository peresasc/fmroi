function checkbox_autogrowingsize_callback(hObject, ~)
% checkbox_autogrowingsize_callback is an internal function of fMROI.
%
% Syntax:
%   checkbox_autogrowingsize_callback(hObject, ~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

handles = guidata(hObject);
n = get(handles.checkbox_autogrowingsize,'Value');

if n
    set(handles.edit_roinvox,'Enable','off')
    set(handles.edit_roinvox,'String','inf')
else
    set(handles.edit_roinvox,'Enable', 'on')
    set(handles.edit_roinvox,'String','50')
end