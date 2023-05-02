function pbutton_brushroiadd_callback(hObject,~)

%--------------------------------------------------------------------------
% add drawn ROI
global st
handles = guidata(hObject);

if isfield(handles,'tbutton_brushroidraw') && handles.tbutton_brushroidraw.Value
    handles.tbutton_brushroidraw.Value = 0;
    guidata(hObject, handles);
    tbutton_roibrush_callback(hObject)
    handles = guidata(hObject);
end

listimgdata = getimgnamelist(hObject);
selaxis = get(handles.popup_workingaxes,'Value'); % select the axis to draw
ucidx = find(contains(listimgdata,'roi_under-construction'), 1); % Image selected as template
wroi = get(handles.popup_workingroi,'Value')-1;
datalut = get(handles.table_roilut,'Data');

centre = zeros(1,3);
for j = 1:3
    centre(j) = str2double(get(handles.edit_pos(1,j),'String'));
end

mask = handles.ax{ucidx,selaxis}.d.CData;
roi = st.roimasks{wroi};

[r0,c0] = ndgrid(1:size(mask,1),1:size(mask,2));
pp0 = [c0(:),r0(:)];

p0 = planar2vol(ucidx,pp0,selaxis,centre);
i0 = sub2ind(size(roi),p0(:,1),p0(:,2),p0(:,3));
roi(i0) = 0;

[row,col] = find(mask==datalut{wroi,1}); % find voxels from selected ROI
planarpos = [col,row];

p = planar2vol(ucidx,planarpos,selaxis,centre);
i = sub2ind(size(roi),p(:,1),p(:,2),p(:,3));
roi(i) = datalut{wroi,1};

roi = uint16(roi);
st.roimasks{wroi} = roi;


guidata(hObject, handles);
updateroitable(hObject)

