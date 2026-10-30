function mousehold(hObject, event)
% mousehold is an internal function of fMROI.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 30/10/2026, peres.asc@gmail.com

handles = guidata(hObject);

% Only activate mousehold if the click occurred over one of the 3 planar slice axes
h = getoverobj('type', 'axes');
if isempty(h)
    handles.mousehold = 0;
    guidata(hObject, handles);
    return;
end

tag = get(h, 'Tag');
if ~contains(tag, 'transversal') && ~contains(tag, 'coronal') && ~contains(tag, 'sagital')
    handles.mousehold = 0;
    guidata(hObject, handles);
    return;
end

if strcmp(event.Source.SelectionType,'normal')
    handles.mousehold = 1;
else
    handles.mousehold = 2;
end
guidata(hObject,handles);