function popup_scrshtmode_callback(hObject,~)

handles = guidata(hObject);

v = get(handles.popup_scrshtmode,'Value');
s = get(handles.popup_scrshtmode,'String');
scrshtmode = s{v};

switch lower(scrshtmode)

    case 'axes'
        del_panel_graphmulti(hObject)
        set(handles.pbutton_genscrsht,'Enable','off')
        guidata(hObject,handles)

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


%--------------------------------------------------------------------------
% generate a new panel_graphmulti
% function create_panel_graphmulti(hObject)
% 
% handles = guidata(hObject);
% 
% panelgraph_pos = [0.26, 0.01,.73,.98];
% 
% handles.panel_graphmulti = uipanel(gcf, 'BackgroundColor','k',...
%         'Units','normalized','Visible','on',...
%         'Position',panelgraph_pos,'Visible','off');
% guidata(hObject,handles)