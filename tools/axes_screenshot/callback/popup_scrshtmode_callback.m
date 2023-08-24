function popup_scrshtmode_callback(hObject,~)

handles = guidata(hObject);

v = get(handles.popup_scrshtmode,'Value');
s = get(handles.popup_scrshtmode,'String');
scrshtmode = s{v};

switch lower(scrshtmode)

    case 'axes'
        del_panel_graphmulti(hObject)
        handles = guidata(hObject);
        set(handles.pbutton_genscrsht,'Enable','off')
        guidata(hObject,handles)
        axes_gui(hObject)

    case 'multi-slice'
        del_panel_graphmulti(hObject)
        handles = guidata(hObject);
        set(handles.pbutton_genscrsht,'Enable','on')
        guidata(hObject,handles)
        multislice_gui(hObject)
    
    case 'mosaic'
        del_panel_graphmulti(hObject)
        handles = guidata(hObject);
        set(handles.pbutton_genscrsht,'Enable','on')
        guidata(hObject,handles)
        mosaic_gui(hObject)
end



%--------------------------------------------------------------------------
% delete panel_graphmulti

function del_panel_graphmulti(hObject)

handles = guidata(hObject);

if isfield(handles,'panel_graphmulti')
    if isobject(handles.panel_graphmulti)
        if isvalid(handles.panel_graphmulti)
            delete(handles.panel_graphmulti)
        end
    end
    handles = updatehandles(handles);
end

guidata(hObject,handles)