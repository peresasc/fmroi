function pbutton_runconnectome_callback(hObject,~)
% pbutton_connectomerun_callback is an internal function of fMROI.
%
% Syntax:
%   pbutton_connectomerun_callback(hObject,~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2024, peres.asc@gmail.com
% Last update: Andre Peres, 06/05/2024, peres.asc@gmail.com

handles = guidata(hObject);

tspath = get(handles.tools.connectome.edit_tspath,'String');
outdir = get(handles.tools.connectome.edit_outdir,'String');

opts = 1;
% opts.saveimg = get(handles.tools.connectome.checkbox_saveimg,'value');
% opts.savestats = get(handles.tools.connectome.checkbox_savestats,'value');
% opts.savets = get(handles.tools.connectome.checkbox_savets,'value');
% opts.groupts = get(handles.tools.connectome.checkbox_groupts,'value');

% if ~(opts.saveimg || opts.savestats || opts.savets)
%     he = errordlg('Please, select at least one type of output!');
%     uiwait(he)
%     return
% end

runconnectome(tspath,outdir,opts,hObject);