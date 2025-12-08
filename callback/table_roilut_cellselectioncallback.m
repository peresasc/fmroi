function table_roilut_cellselectioncallback(hObject,eventdata)


handles = guidata(hObject);

if ~isempty(eventdata.Indices)
    handles.selected_roi_row = eventdata.Indices(1,1);
else
    handles.selected_roi_row = [];
end

guidata(hObject,handles);