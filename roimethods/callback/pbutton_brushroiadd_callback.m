function pbutton_brushroiadd_callback(hObject,~)

%--------------------------------------------------------------------------
% add drawn ROI
global st
handles = guidata(hObject);

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
[row,col] = find(mask==datalut{wroi,1}); % find voxels from selected ROI
planarpos = [col,row];


roi = st.roimasks{wroi};
p = planar2vol(ucidx,planarpos,selaxis,centre);
i = sub2ind(size(roi),p(:,1),p(:,2),p(:,3));

roi(i) = datalut{wroi,1};
st.roimasks{wroi} = roi;


guidata(hObject, handles);
updateroitable(hObject)

