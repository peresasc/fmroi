function pbutton_connectomeselectfiles_callback(hObject,~)
% pbutton_connectomeselectfiles_callback is an internal function of fMROI.
%
% Syntax:
%   pbutton_connectomeselectfiles_callback(hObject,~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2024, peres.asc@gmail.com
% Last update: Andre Peres, 15/05/2024, peres.asc@gmail.com

handles = guidata(hObject);

switch hObject
    case handles.tools.connectome.pbutton_tspath
        extfilt = {'*.mat';'*.txt';'*.csv';'*.tsv'};
        [fn,pn,idx] = uigetfile(extfilt,'Select the time-series files','MultiSelect','on');
        if ~idx
            return
        end
        if iscell(fn)
            strpath = fullfile(pn,fn{1});
            for i = 2:length(fn)
                strpath = [strpath,';',fullfile(pn,fn{i})];
            end
            set(handles.tools.connectome.edit_tspath,'String',strpath);
        else
            set(handles.tools.connectome.edit_tspath,'String',fullfile(pn,fn));
        end

    case handles.tools.connectome.pbutton_roinamepath
        extfilt = {'*.mat';'*.txt';'*.csv';'*.tsv'};
        [fn,pn,idx] = uigetfile(extfilt,'Select the ROI names file');
        if ~idx
            return
        end
        if iscell(fn)
            strpath = fullfile(pn,fn{1});
            for i = 2:length(fn)
                strpath = [strpath,';',fullfile(pn,fn{i})];
            end
            set(handles.tools.connectome.edit_roinamepath,'String',strpath);
        else
            set(handles.tools.connectome.edit_roinamepath,'String',fullfile(pn,fn));
        end

    case handles.tools.connectome.pbutton_outdir
        outdir = uigetdir(pwd,'Select the output folder:');
        set(handles.tools.connectome.edit_outdir,'String',outdir);
end

guidata(hObject,handles)