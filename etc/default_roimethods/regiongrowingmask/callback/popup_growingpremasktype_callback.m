function popup_growingpremasktype_callback(hObject, ~)
% popup_growingpremasktype_callback is an internal function of fMROI.
%
% Syntax:
%   popup_growingpremasktype_callback(hObject, ~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 28/08/2023, peres.asc@gmail.com

handles = guidata(hObject);
v = get(handles.popup_growingpremasktype,'Value');
s = get(handles.popup_growingpremasktype,'String');
premaskmth = lower(s{v});

switch premaskmth
    case 'mask'
        set(handles.text_maskimg,'Visible', 'on')
        set(handles.popup_maskimg,'Visible', 'on')
        set(handles.edit_growingpremasradius,'Visible', 'off')
        set(handles.text_growingpremasradius,'Visible', 'off')
    case 'sphere'
        set(handles.text_maskimg,'Visible', 'off')
        set(handles.popup_maskimg,'Visible', 'off')
        set(handles.edit_growingpremasradius,'Visible', 'on')
        set(handles.text_growingpremasradius,'Visible', 'on')
    case 'none'
        set(handles.text_maskimg,'Visible', 'off')
        set(handles.popup_maskimg,'Visible', 'off')
        set(handles.edit_growingpremasradius,'Visible', 'off')
        set(handles.text_growingpremasradius,'Visible', 'off')
end



guidata(hObject, handles);