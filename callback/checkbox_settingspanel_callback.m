function checkbox_settingspanel_callback(hObject, ~)

handles = guidata(hObject);


switch hObject
    case handles.tools.settings.checkbox_butter
        btnval = get(hObject,'Value');

        if btnval
            set(handles.panel_filter,'Visible','on')
        else
            set(handles.panel_filter,'Visible','off')
        end

    case handles.tools.settings.checkbox_regressout
        btnval = get(hObject,'Value');

        if btnval
            set(handles.panel_regressout,'Visible','on')
        else
            set(handles.panel_regressout,'Visible','off')
        end

    case handles.tools.settings.checkbox_smooth
        btnval = get(hObject,'Value');

        if btnval
            set(handles.panel_smooth,'Visible','on')
        else
            set(handles.panel_smooth,'Visible','off')
        end
end

guidata(hObject,handles)