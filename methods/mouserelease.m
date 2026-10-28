function mouserelease(hObject, ~)

handles = guidata(hObject);
was_held = handles.mousehold;
handles.mousehold = 0;
guidata(hObject, handles);

if was_held
    update_coordinates(hObject);
end