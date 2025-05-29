function pbutton_panelsettingssaveopts_callback(hObject,~)

getopts(hObject)
handles = guidata(hObject);

if isfield(handles,'opts')
    opts = handles.opts;
else
    he = errordlg('The structure "handles" does not contain the required field "opts".', ...
        'Missing Field');
    uiwait(he)
    return
end

% Prompt user to choose filename and path using uiputfile
[fn,pn,idx] = uiputfile({'*.mat','MAT-files (*.mat)'}, ...
    'Save opts structure as', 'opts.mat');

% If user cancels the dialog, exit the function
if idx == 0
    disp('User canceled file selection.');
    return;
end

% Ensure the filename has the .mat extension
[~,name,ext] = fileparts(fn);
if ~strcmpi(ext, '.mat')
    fn = [name, '.mat'];  % Add or replace with .mat
end

% Build full path and save opts
fullpath = fullfile(pn,fn);
save(fullpath,'opts');

set(handles.text_panelsettingsstatus,'String','Structure opts saved!')

guidata(hObject,handles)
