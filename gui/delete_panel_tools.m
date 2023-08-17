function delete_panel_tools(hObject,~)

handles = guidata(hObject);

if isfield(handles,'panel_tools')
    if isobject(handles.panel_tools)
        if isvalid(handles.panel_tools)
            delete(handles.panel_tools)
        end
    end
    handles = updatehandles(handles);
end

guidata(handles.fig,handles);