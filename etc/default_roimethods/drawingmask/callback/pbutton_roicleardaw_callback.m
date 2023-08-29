function pbutton_roicleardaw_callback(hObject,~)

handles = guidata(hObject);

if isfield(handles, 'drawingroi') &&...
        isfield(handles.drawingroi,'hroi') &&...
        ishandle(handles.drawingroi.hroi)
    delete(handles.drawingroi.hroi)
    guidata(hObject,handles);
end