function toolbarselection(hObject, event)

handles = guidata(hObject);

if strcmp(event.Selection.Value,'on')
   handles.toolbar = 1;
else
   handles.toolbar = 0 ;
end

guidata(hObject,handles);