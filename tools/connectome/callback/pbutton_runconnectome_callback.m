function pbutton_runconnectome_callback(hObject,~)
% pbutton_runconnectome_callback is an internal function of fMROI.
%
% Syntax:
%   pbutton_runconnectome_callback(hObject,~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2024, peres.asc@gmail.com
% Last update: Andre Peres, 06/05/2024, peres.asc@gmail.com

handles = guidata(hObject);

set(handles.tools.connectome.text_wb,'String','Initializing...')
pause(.1)
tspath = get(handles.tools.connectome.edit_tspath,'String');
roinames = get(handles.tools.connectome.edit_roinamepath,'String');
outdir = get(handles.tools.connectome.edit_outdir,'String');

opts.rsave = get(handles.tools.connectome.checkbox_rsave,'value');
opts.psave = get(handles.tools.connectome.checkbox_psave,'value');
opts.zsave = get(handles.tools.connectome.checkbox_zsave,'value');
opts.ftsave = get(handles.tools.connectome.checkbox_ftsave,'value');
opts.higpass = get(handles.tools.connectome.edit_highpass,'string');
opts.lowpass = get(handles.tools.connectome.edit_lowpass,'string');

if ~(opts.rsave || opts.zsave || opts.ftsave)
    he = errordlg('Please, select at least one type of output!');
    uiwait(he)
    return
end

runconnectome(tspath,outdir,roinames,opts,hObject);