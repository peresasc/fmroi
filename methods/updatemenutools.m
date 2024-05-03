function updatemenutools(hObject)
% updatemenutools is an internal function of fMROI. It seraches for folders
% into [fmroiroot]/tools directory, and atributes a entry in the Tools
% menu in the main fMROI interface.
%
% Syntax:
%   updatemenutools(hObject)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2023, peres.asc@gmail.com
% Last update: Andre Peres, 24/08/2023, peres.asc@gmail.com

handles = guidata(hObject);

%--------------------------------------------------------------------------
% Delete previous Load Template menu

if isfield(handles,'hmenutools_apps')
    lentools = length(handles.hmenutools_apps);
    for j = lentools:-1:1
        if ishandle(handles.hmenutools_apps(j))
            delete(handles.hmenutools_apps(j))
        end
    end
end
handles.hmenutools_apps = [];

%--------------------------------------------------------------------------
% Generate the new Load Template menu

dn = dir(handles.toolsdir);

auxdel = [];
for i = 1:length(dn)
    if strcmp(dn(i).name,'.') || strcmp(dn(i).name,'..') || ~dn(i).isdir
        auxdel = [auxdel,i];
    end
end
dn(auxdel) = [];

for i = 1:length(dn)
    handles.hmenutools_apps(i) = uimenu(handles.hmenutools,...
        'Label',dn(i).name,'Callback',eval(['@',dn(i).name]));
end


guidata(hObject,handles);