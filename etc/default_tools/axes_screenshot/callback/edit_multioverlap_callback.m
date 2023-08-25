function edit_multioverlap_callback(hObject, ~)
% edit_multioverlap_callback is an internal function of fMROI.
%
% Syntax:
%   edit_multioverlap_callback(hObject, ~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2023, peres.asc@gmail.com
% Last update: Andre Peres, 22/08/2023, peres.asc@gmail.com

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

set(handles.slider_multioverlap,'Value',sv)

guidata(hObject,handles);
