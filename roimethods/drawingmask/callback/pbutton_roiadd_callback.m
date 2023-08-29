function pbutton_roiadd_callback(hObject,~)

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

    maxidx = max(roi(:));
     
    if maxidx
        idx = maxidx;
    else
        idx = 1;
    end

    roi(i) = idx;
    roi = uint16(roi);
    st.roimasks{wroi} = roi;
else
    datalut = get(handles.table_roilut,'Data');
    if  isempty(datalut{1,1})
        roi_idx = [];
    else
        roi_idx = cellfun(@uint16,datalut(:,1));
    end

    n = handles.table_selectedcell(1); % idex of the selected template image
    srcvol = st.vols{n}.private.dat(:,:,:);
    roi = zeros(size(srcvol));

    p = planar2vol(selimg,planarpos,selaxis,refpos);
    i = sub2ind(size(roi),p(:,1),p(:,2),p(:,3));
    roi(i) = 1;
    roi = uint16(roi);

    if isfield(st,'roimasks') && ~isempty(roi_idx)        
        roi(logical(roi)) =...
            roi(logical(roi)) + max(roi_idx);
        st.roimasks{end+1} = roi;
    else
        st.roimasks{1} = roi;
    end
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