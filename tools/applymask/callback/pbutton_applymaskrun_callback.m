function pbutton_applymaskrun_callback(hObject, ~)
% pbutton_applymaskrun_callback is an internal function of fMROI.
%
% Syntax:
%   pbutton_applymaskrun_callback(hObject,~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2024, peres.asc@gmail.com
% Last update: Andre Peres, 06/05/2024, peres.asc@gmail.com

handles = guidata(hObject);

srcpath = get(handles.tools.applymask.edit_scrpath,'String');
maskpath = get(handles.tools.applymask.edit_maskpath,'String');
outdir = get(handles.tools.applymask.edit_outdir,'String');

opts.saveimg = get(handles.tools.applymask.checkbox_saveimg,'value');
opts.savestats = get(handles.tools.applymask.checkbox_savestats,'value');
opts.savets = get(handles.tools.applymask.checkbox_savets,'value');

if ~(opts.saveimg || opts.savestats || opts.savets)
    he = errordlg('Please, select at least one type of output!');
    uiwait(he)
    return
end


runapplymask(srcpath,maskpath,outdir,opts,hObject);