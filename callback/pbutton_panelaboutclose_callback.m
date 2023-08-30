function pbutton_panelaboutclose_callback(hObject,~)

handles = guidata(hObject);

if isfield(handles,'panel_about')
    if isobject(handles.panel_about)
        if isvalid(handles.panel_about)
            delete(handles.panel_about)
        end
    end
    handles = updatehandles(handles);
end


guidata(handles.fig,handles);