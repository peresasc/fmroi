function pbutton_roidraw_callback(hObject,~)

global st
handles = guidata(hObject);

if isfield(handles, 'drawingroi') &&...
        isfield(handles.drawingroi,'hroi') &&...
        ishandle(handles.drawingroi.hroi)
    delete(handles.drawingroi.hroi)
end

n = find(~cellfun(@isempty,st.vols), 1, 'last');

drawtype = lower(handles.buttongroup_drawtype.SelectedObject.String);

selimg = handles.table_selectedcell(1);
selaxis = get(handles.popup_workingaxes,'Value');
top_ax = handles.ax{n,selaxis}.ax;

switch drawtype

    case 'freehand'
        handles.drawingroi.hroi = drawfreehand(top_ax);

    case 'polygon'
        handles.drawingroi.hroi = drawpolygon(top_ax);
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