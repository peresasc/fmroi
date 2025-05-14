function delete_panel_settings(hObject,~)

handles = guidata(hObject);

if isfield(handles,'panel_settings')
    if isobject(handles.panel_settings)
        if isvalid(handles.panel_settings)
            delete(handles.panel_settings)
        end
    end
    handles = updatehandles(handles);
end

guidata(handles.fig,handles);