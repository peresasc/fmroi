function keypress_callback(hObject, eventData)

handles = guidata(hObject);

cpima = [str2double(get(handles.edit_pos(2,1),'String')),...
             str2double(get(handles.edit_pos(2,2),'String')),...
             str2double(get(handles.edit_pos(2,3),'String')),...
             1];

switch eventData.Key

    case 'leftarrow'
        cpima(1) = cpima(1) - 1;
        set(handles.edit_pos(2,1),'String',num2str(cpima(1)))
        editpos_callback(hObject,[],'edit23')
    case 'rightarrow'
        cpima(1) = cpima(1) + 1;
        set(handles.edit_pos(2,1),'String',num2str(cpima(1)))
        editpos_callback(hObject,[],'edit23')
    case 'uparrow'
        cpima(2) = cpima(2) + 1;
        set(handles.edit_pos(2,2),'String',num2str(cpima(2)))
        editpos_callback(hObject,[],'edit23')
    case 'downarrow'
        cpima(2) = cpima(2) - 1;
        set(handles.edit_pos(2,2),'String',num2str(cpima(2)))
        editpos_callback(hObject,[],'edit23')
    case 'pageup'
        cpima(3) = cpima(3) + 1;
        set(handles.edit_pos(2,3),'String',num2str(cpima(3)))
        editpos_callback(hObject,[],'edit23')
    case 'pagedown'
        cpima(3) = cpima(3) - 1;
        set(handles.edit_pos(2,3),'String',num2str(cpima(3)))
        editpos_callback(hObject,[],'edit23')
    case 'add'
        if ~isempty(eventData.Modifier) &&...
                strcmp(eventData.Modifier{:},'control')
            fontsize_increase(hObject);
        end
    case 'subtract'
        if ~isempty(eventData.Modifier) &&...
                strcmp(eventData.Modifier{:},'control')
            fontsize_decrease(hObject);
        end
end
