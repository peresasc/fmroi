function menuconfig_imptpl_callback(hObject,~)
% menuconfig_imptpl_callback is an internal function of fMROI.
%
% Syntax:
%   menuconfig_imptpl_callback(hObject,~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

handles = guidata(hObject);
pn = uigetfile_n_dir(pwd,'Select One or More Nifti Files or Folders');


if ~isempty(pn)
    for i = 1:length(pn)
        if isfile(pn{i})
            copyfile(pn{i},handles.tpldir);
        else
            [~, fn] = fileparts(pn{i});
            copyfile(pn{i},fullfile(handles.tpldir,fn));
        end
    end
    
    % Update the templates submenus
    guidata(hObject,handles);
    updatemenutemplate(hObject);
    handles = guidata(hObject);
end

