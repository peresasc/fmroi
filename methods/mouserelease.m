function mouserelease(hObject, ~)

handles = guidata(hObject);
handles.mousehold = 0;
guidata(hObject,handles);