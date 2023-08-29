function menuconfig_imptools_callback(hObject,~)
% menuconfig_imptools_callback is an internal function of fMROI.
%
% Syntax:
%   menuconfig_imptools_callback(hObject,~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2023, peres.asc@gmail.com
% Last update: Andre Peres, 25/08/2023, peres.asc@gmail.com

handles = guidata(hObject);
pn = uigetfile_n_dir(pwd,'Select one or more folders');

auxdel = [];
for i = 1:length(pn)
    if isfile(pn{i})
        auxdel = [auxdel,i];
    end
end
pn(auxdel) = [];

if ~isempty(pn)
    for i = 1:length(pn)
        [~, dn] = fileparts(pn{i});
        copyfile(pn{i},fullfile(handles.toolsdir,dn));
    end

    % Update the templates submenus
    guidata(hObject,handles)
    updatemenutools(hObject)
end

