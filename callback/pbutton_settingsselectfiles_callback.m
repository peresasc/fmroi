function pbutton_settingsselectfiles_callback(hObject,~)
% pbutton_settingsselectfiles_callback is an internal function of fMROI.
%
% Syntax:
%   pbutton_connectomeselectfiles_callback(hObject,~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2025, peres.asc@gmail.com
% Last update: Andre Peres, 21/05/2024, peres.asc@gmail.com

handles = guidata(hObject);

switch hObject
    case handles.tools.settings.pbutton_confoundspath
        extfilt = {'*.mat';'*.txt';'*.csv';'*.tsv'};
        [fn,pn,idx] = uigetfile(extfilt,'Select the confounds file','MultiSelect','off');
        if ~idx
            return
        end

        set(handles.tools.settings.edit_confoundspath,'String',fullfile(pn,fn));

    case handles.tools.settings.pbutton_selconf
        extfilt = {'*.mat';'*.txt';'*.csv';'*.tsv'};
        [fn,pn,idx] = uigetfile(extfilt,'Select the confounds file','MultiSelect','off');
        if ~idx
            return
        end

        set(handles.tools.settings.edit_selconf,'String',fullfile(pn,fn));

    case handles.tools.settings.pbutton_brainmaskpath
        extfilt = {'*.nii.gz';'*.nii'};
        [fn,pn,idx] = uigetfile(extfilt,'Select the brainmask file','MultiSelect','off');
        if ~idx
            return
        end

        set(handles.tools.settings.edit_brainmaskpath,'String',fullfile(pn,fn));

end