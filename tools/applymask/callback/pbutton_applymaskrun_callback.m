function pbutton_applymaskrun_callback(hObject, ~)
% pbutton_applymaskrun_callback is an internal function of fMROI.
%
% Syntax:
%   pbutton_applymaskrun_callback(hObject,~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2023, peres.asc@gmail.com
% Last update: Andre Peres, 22/08/2023, peres.asc@gmail.com

handles = guidata(hObject);

srcpath = get(handles.tools.applymask.edit_scrpath,'String');
maskpath = get(handles.tools.applymask.edit_maskpath,'String');
outdir = get(handles.tools.applymask.edit_outdir,'String');

runapplymask(hObject,srcpath,maskpath,outdir);