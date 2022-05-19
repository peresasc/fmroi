function menufile_tplopen_callback(hObject, eventData)
% menufile_tplopen_callback is an internal function of fMROI.
%
% Syntax:
%   menufile_tplopen_callback(hObject, eventData)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%   eventData: conveys information about changes or actions that occurred
%              within the menufile_tplopen.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

handles = guidata(hObject);

fn = eventData.Source.Text;

auxparent = eventData.Source.Parent;
parent{1} = auxparent.Text;
count = 1;
while ~strcmpi(parent{count},'Load Template')
    count = count + 1;
    auxparent = auxparent.Parent;
    parent{count} = auxparent.Text;    
end
parent(end) = [];
pn = [];
for i = length(parent):-1:1
pn = fullfile(pn,parent{i});
end

filename = fullfile(handles.tpldir,pn,fn);
if strcmp(filename(end-1:end),'gz')
    gunzip(filename,handles.tmpdir);
    filename = fullfile(handles.tmpdir,fn(1:end-3));
end
show_slices(hObject, filename)

