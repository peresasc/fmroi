function slider_alpha_callback(hObject, ~)
% slider_alpha_callback is an internal function of fMROI.
%
% Syntax:
%   slider_alpha_callback(hObject, ~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

handles = guidata(hObject);

n = handles.table_selectedcell(1);

handles.imgprop(n).alpha = get(handles.slider_alpha,'Value');

guidata(hObject, handles);

draw_slices(hObject)