function checkbox_savets_callback(hObject,~)
% checkbox_savets_callback is an internal function of fMROI.
%
% Syntax:
%   checkbox_savets_callback(hObject,~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2024, peres.asc@gmail.com
% Last update: Andre Peres, 15/05/2024, peres.asc@gmail.com

handles = guidata(hObject);

v = get(handles.tools.applymask.checkbox_savets,'value');

if v
    set(handles.tools.applymask.checkbox_groupts,'Enable','on')
else
    set(handles.tools.applymask.checkbox_groupts,'Enable','off')
end

guidata(hObject,handles);