function pbutton_roidraw_callback(hObject,~)

handles = guidata(hObject);

if isfield(handles, 'drawingroi') &&...
        isfield(handles.drawingroi,'hroi') &&...
        ishandle(handles.drawingroi.hroi)
    delete(handles.drawingroi.hroi)
end

drawtype = lower(handles.buttongroup_drawtype.SelectedObject.String);

selimg = handles.table_selectedcell(1);
selaxis = get(handles.popup_workingaxes,'Value');
ax = handles.ax{selimg,selaxis}.ax;

switch drawtype

    case 'freehand'
        handles.drawingroi.hroi = drawfreehand(ax);

    case 'polygon'
        handles.drawingroi.hroi = drawpolygon(ax);
end

centre = zeros(1,3);
for j = 1:3
    centre(j) = str2double(get(handles.edit_pos(1,j),'String'));
end

handles.drawingroi.selimg = selimg;
handles.drawingroi.himg = handles.ax{selimg,selaxis}.d;
handles.drawingroi.axistag = selaxis;
handles.drawingroi.refpos = centre;

guidata(hObject,handles);