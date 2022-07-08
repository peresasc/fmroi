function pbutton_pbutton_roirem_callback(hObject,~)

global st
handles = guidata(hObject);

if ~isfield(handles, 'drawingroi') ||...
        ~isfield(handles.drawingroi,'hroi') ||...
        ~ishandle(handles.drawingroi.hroi)
    return
end

wroi = get(handles.popup_workingroi,'Value')-1;
selaxis = handles.drawingroi.axistag;
refpos = handles.drawingroi.refpos;
selimg = handles.drawingroi.selimg;

mask = createMask(handles.drawingroi.hroi,handles.drawingroi.himg);
[row,col] = find(mask);
planarpos = [col,row];

listimgdata = getimgnamelist(hObject);
st.roisrcname = listimgdata{selimg};

if wroi
    roi = st.roimasks{wroi};
    p = planar2vol(selimg,planarpos,selaxis,refpos);
    i = sub2ind(size(roi),p(:,1),p(:,2),p(:,3));

    roi(i) = 0;
    st.roimasks{wroi} = roi;
else
    he = errordlg('There is no ROI to be removed! Please, select a ROI first.');
    uiwait(he)
    return 
end

delete(handles.drawingroi.hroi)
guidata(hObject, handles);
updateroitable(hObject)
handles = guidata(hObject);

datalut = get(handles.table_roilut,'Data');
set(handles.popup_workingroi,'String',[{'new'};datalut(:,2)])

if wroi
    set(handles.popup_workingroi,'Value',wroi+1);   
else
    set(handles.popup_workingroi,'Value',size(datalut,1)+1);
end
guidata(hObject, handles);