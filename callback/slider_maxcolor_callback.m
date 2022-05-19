function slider_maxcolor_callback(hObject, ~)
% slider_maxcolor_callback is an internal function of fMROI.
%
% Syntax:
%   slider_maxcolor_callback(hObject, ~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

handles = guidata(hObject);

n = handles.table_selectedcell(1);

handles.imgprop(n).maxcolor = get(handles.slider_maxcolor,'Value');

guidata(hObject, handles);

% draw_slices(hObject)
popup_colormap_callback(hObject, [])