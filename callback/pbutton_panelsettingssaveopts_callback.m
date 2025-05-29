function pbutton_panelsettingssaveopts_callback(hObject,~)

getopts(hObject)
handles = guidata(hObject);

% if isfield(handles,'opts')
%     opts = handles.opts;
% else
% 
% end
% 
% 
% % Prompt user to choose filename and path using uiputfile
% [filename, pathname] = uiputfile({'*.mat','MAT-files (*.mat)'}, ...
%     'Save opts structure as', 'opts.mat');
% 
% % If user cancels the dialog, exit the function
% if isequal(filename, 0) || isequal(pathname, 0)
%     disp('User canceled file selection.');
%     return;
% end
% 
% % Ensure the filename has the .mat extension
% [~, name, ext] = fileparts(filename);
% if ~strcmpi(ext, '.mat')
%     filename = [name, '.mat'];  % Add or replace with .mat
% end
% 
% % Build full path and save opts
% fullpath = fullfile(pathname, filename);
% save(fullpath, 'opts');
% 
% disp(['opts structure saved to: ', fullpath]);
