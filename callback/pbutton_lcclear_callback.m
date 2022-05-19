function pbutton_lcclear_callback(hObject, ~)
% pbutton_lcclear_callback is an internal function of fMROI.
%
% Syntax:
%   pbutton_lcclear_callback(hObject, ~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

handles = guidata(hObject);

d = cell(10,2);
set(handles.table_roilc,'Data',d)

guidata(hObject, handles);