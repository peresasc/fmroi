function popup_roicolor_callback(hObject, ~)
% popup_roicolor_callback is an internal function of fMROI.
%
% Syntax:
%   popup_roicolor_callback(hObject, ~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

handles = guidata(hObject);
n = handles.table_selectedcell(1);

if ~handles.imgprop(n).viewrender
    return
end

v = get(handles.popup_roicolor,'Value');
s = get(handles.popup_roicolor,'String');
c = s{v};

handles.ax{n,4}.roipatch.FaceColor = c;
handles.imgprop(n).roicolor = v;

guidata(hObject, handles);