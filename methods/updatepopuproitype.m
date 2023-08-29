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
% Last update: Andre Peres, 29/08/2023, peres.asc@gmail.com

handles = guidata(hObject);

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

set(handles.popup_roitype,'String',roimth)

guidata(hObject,handles);