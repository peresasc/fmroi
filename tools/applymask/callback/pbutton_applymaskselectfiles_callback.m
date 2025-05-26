function pbutton_applymaskselectfiles_callback(hObject,~)
% pbutton_applymaskselectfiles_callback is an internal function of fMROI.
%
% Syntax:
%   pbutton_applymaskselectfiles_callback(hObject,~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2024, peres.asc@gmail.com
% Last update: Andre Peres, 06/05/2024, peres.asc@gmail.com

handles = guidata(hObject);


switch hObject
    case handles.tools.applymask.pbutton_srcpath
        extfilt = {'*.nii.gz';'*.nii';'*.txt';'*.csv';'*.tsv'};
        [fn,pn,idx] = uigetfile(extfilt,'Select the source files','MultiSelect','on');
        if ~idx
            return
        end
        if iscell(fn)
            strpath = fullfile(pn,fn{1});
            for i = 2:length(fn)
                strpath = [strpath,';',fullfile(pn,fn{i})];
            end
            set(handles.tools.applymask.edit_scrpath,'String',strpath);
        else
            set(handles.tools.applymask.edit_scrpath,'String',fullfile(pn,fn));
        end

    case handles.tools.applymask.pbutton_maskpath
        extfilt = {'*.nii.gz';'*.nii';'*.txt';'*.csv';'*.tsv'};
        [fn,pn,idx] = uigetfile(extfilt,'Select the mask files','MultiSelect','on');
        if ~idx
            return
        end
        if iscell(fn)
            strpath = fullfile(pn,fn{1});
            for i = 2:length(fn)
                strpath = [strpath,';',fullfile(pn,fn{i})];
            end
            set(handles.tools.applymask.edit_maskpath,'String',strpath);
        else
            set(handles.tools.applymask.edit_maskpath,'String',fullfile(pn,fn));
        end

    case handles.tools.applymask.pbutton_outdir
        outdir = uigetdir(pwd,'Select the output folder:');
        set(handles.tools.applymask.edit_outdir,'String',outdir);
end

guidata(hObject,handles)