function menufile_open_callback(hObject, ~)
% menufile_open_callback is an internal function of fMROI.
%
% Syntax:
%   menufile_open_callback(hObject, ~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

handles = guidata(hObject);

[fn, pn, idx] = uigetfile({'*.nii';'*.nii.gz'},...
    'Select One or More Nifti Files', ...
    'MultiSelect', 'on');
handles.fileopenidx = idx;
guidata(hObject,handles);

if idx
    if iscell(fn)
        for i = 1:length(fn)
            filename = fullfile(pn,fn{i});
            if strcmp(filename(end-1:end),'gz')
                gunzip(filename,handles.tmpdir);
                filename = fullfile(handles.tmpdir,fn{i}(1:end-3));
            end
            show_slices(hObject, filename)
        end
    else
        filename = fullfile(pn,fn);
        if strcmp(filename(end-1:end),'gz')
            gunzip(filename,handles.tmpdir);
            filename = fullfile(handles.tmpdir,fn(1:end-3));
        end
        show_slices(hObject, filename)
    end
end