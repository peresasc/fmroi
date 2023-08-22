function pbutton_genscrsht_callback(hObject,~)

handles = guidata(hObject);

v = get(handles.popup_scrshtmode,'Value');
s = get(handles.popup_scrshtmode,'String');
scrshtmode = s{v};

switch lower(scrshtmode)

    case 'axes'


    case 'multi-slice'
        multislice(hObject)
    
    case 'mosaic'
        mosaic(hObject)
end
