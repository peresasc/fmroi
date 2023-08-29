function panel_drawtools_deletefcn(hObject,~)

handles = guidata(hObject);

if isfield(handles,'tbutton_brushroidraw') &&...
        isvalid(handles.tbutton_brushroidraw) &&...
        handles.tbutton_brushroidraw.Value
    
    handles.tbutton_brushroidraw.Value = 0;
    guidata(hObject, handles);
    tbutton_roibrush_callback(hObject)
end