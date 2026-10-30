function mouserelease(hObject, ~)
% mouserelease is an internal function of fMROI.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 30/10/2026, peres.asc@gmail.com

handles = guidata(hObject);
was_held = handles.mousehold;
handles.mousehold = 0;
guidata(hObject, handles);

if was_held
    update_coordinates(hObject);
end