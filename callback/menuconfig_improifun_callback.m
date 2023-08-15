function menuconfig_improifun_callback(hObject, ~)
% menuconfig_improifun_callback is an internal function of fMROI.
%
% Syntax:
%   menuconfig_improifun_callback(hObject, ~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

handles = guidata(hObject);
pn = uigetfile_n_dir(pwd,'Select one or more folders to be imported');


if ~isempty(pn)
    for j = 1:length(pn)
        if isfile(pn{j}) % tests if is file and send a warning message
            opts = struct('WindowStyle','replace',...
                'Interpreter','tex');
            he1 = warndlg({...
                'Oops! It looks like you selected files instead of folders.';...
                '\bf Only files inside selected folders will be imported.'},...
                'Importing Error',opts);
        else
            d = dir(pn{j});
            [~,mainfn,~] = fileparts(pn{j});
            if isfile([pn{j},filesep,mainfn,'.m']) % tests if the method script exists (same name as its folder), otherwise skip.
                for i = 1:length(d)
                    if isfile(d(i).name) % tests if it is a file, otherwise skip.
                        filename = fullfile(pn{j},d(i).name);
                        [~,curfn,curxt] = fileparts(filename);
                        curfnxt = [curfn,curxt];

                        if strcmp(curfn,mainfn)
                            copyfile(filename,fullfile(handles.fmroirootdir,...
                                'roimethods','methods'));

                        elseif length(curfnxt)>6 && strcmpi(curfnxt(end-5:end),'_gui.m')
                            copyfile(filename,fullfile(handles.fmroirootdir,...
                                'roimethods','gui'));

                        elseif length(curfnxt)>9 && strcmpi(curfnxt(end-8:end),'_caller.m')
                            copyfile(filename,fullfile(handles.fmroirootdir,...
                                'roimethods','gui'));

                        else
                            copyfile(filename,fullfile(handles.fmroirootdir,...
                                'roimethods','callback'));
                        end
                    end
                end
            else
                opts = struct('WindowStyle','replace',...
                    'Interpreter','tex');
                he2 = warndlg({...
                    'The selected method does not match the name of the containing folder.';...
                    'To ensure proper importing, please make sure the method file name exactly matches the folder name.'},...
                    'File Naming Mismatch Error',opts);
            end
        end
    end
    guidata(hObject,handles);
    updatepopuproitype(hObject)
end