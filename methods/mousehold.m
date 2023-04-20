function mousehold(hObject, event)

handles = guidata(hObject);
if strcmp(event.Source.SelectionType,'normal')
    handles.mousehold = 1;
else
    handles.mousehold = 2;
end
guidata(hObject,handles);