function updatepopuproitype(hObject)
% updatepopuproitype is an internal function of fMROI. It updates the
% popu_up roi_type contents.
%
% Syntax:
%   updatepopuproitype(hObject)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

handles = guidata(hObject);

% methodspath = fullfile(handles.fmroirootdir,'roimethods','methods','*.m');
% methodstruc = dir(methodspath);

dn = dir(handles.roimethdir);

auxdel = [];
for i = 1:length(dn)
    if strcmp(dn(i).name,'.') || strcmp(dn(i).name,'..') || ~dn(i).isdir
        auxdel = [auxdel,i];
    end
end
dn(auxdel) = [];

roimth = cell(length(dn),1);
for i = 1:length(dn)
roimth{i} = dn(i).name;
end

% for i = 1:length(methodstruc)
% [~,roimth{i},~] = fileparts(methodstruc(i).name);
% end

set(handles.popup_roitype,'String',roimth)

guidata(hObject,handles);