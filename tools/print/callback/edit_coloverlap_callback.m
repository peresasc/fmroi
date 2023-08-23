function edit_coloverlap_callback(hObject,~)
% edit_coloverlap_callback is an internal function of fMROI.
%
% Syntax:
%   edit_coloverlap_callback(hObject,~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2023, peres.asc@gmail.com
% Last update: Andre Peres, 23/08/2023, peres.asc@gmail.com

handles = guidata(hObject);

try
    v = str2double(get(hObject,'String'));
catch
    he = errordlg('Input value must be numeric!','Type Error');
    uiwait(he)
    return
end

if v < -1
    v = -1;
    set(hObject,'String',v)
elseif v > 1
    v = 1;
    set(hObject,'String',v)
end

sv = (v+1)/2;

set(handles.slider_coloverlap,'Value',sv)

guidata(hObject,handles);
