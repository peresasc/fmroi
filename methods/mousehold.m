function mousehold(hObject, ~)

handles = guidata(hObject);
handles.mousehold = 1;
guidata(hObject,handles);