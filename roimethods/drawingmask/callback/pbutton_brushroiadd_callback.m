function pbutton_brushroiadd_callback(hObject,~)
% pbutton_brushroiadd_callback is an internal function of fMROI.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 28/10/2026, peres.asc@gmail.com

%--------------------------------------------------------------------------
% add drawn ROI
global st
handles = guidata(hObject);

% Save brushmask before toggling off brush draw button
brushmask = [];
if isfield(handles, 'drawingroi') && isfield(handles.drawingroi, 'brushmask')
    brushmask = handles.drawingroi.brushmask;
end

if isfield(handles,'tbutton_brushroidraw') && handles.tbutton_brushroidraw.Value
    handles.tbutton_brushroidraw.Value = 0;
    guidata(hObject, handles);
    tbutton_roibrush_callback(hObject)
    handles = guidata(hObject);
end

listimgdata = getimgnamelist(hObject);
selaxis = get(handles.popup_workingaxes,'Value'); % select the axis to draw
ucidx = find(contains(listimgdata,'roi_under-construction'), 1); % Image selected as template
if isempty(ucidx)
    ucidx = find(~cellfun(@isempty,st.vols), 1, 'last');
end
wroi = get(handles.popup_workingroi,'Value')-1;
datalut = get(handles.table_roilut,'Data');

centre = zeros(1,3);
for j = 1:3
    centre(j) = str2double(get(handles.edit_pos(1,j),'String'));
end

if ~isempty(brushmask)
    mask = brushmask;
else
    slices = getslices(st, ucidx);
    mask = slices{selaxis};
end

roi = st.roimasks{wroi};

[r0,c0] = ndgrid(1:size(mask,1),1:size(mask,2));
pp0 = [c0(:),r0(:)];

p0 = planar2vol(ucidx,pp0,selaxis,centre);
i0 = sub2ind(size(roi),p0(:,1),p0(:,2),p0(:,3));
roi(i0) = 0;

roi_val = datalut{wroi, 1};
if iscell(roi_val), roi_val = roi_val{1}; end

[row,col] = find(mask == roi_val); % find voxels from selected ROI
planarpos = [col,row];

p = planar2vol(ucidx,planarpos,selaxis,centre);
i = sub2ind(size(roi),p(:,1),p(:,2),p(:,3));
roi(i) = roi_val;

roi = uint16(roi);
st.roimasks{wroi} = roi;

if isfield(handles, 'drawingroi') && isfield(handles.drawingroi, 'hbrush') && ishandle(handles.drawingroi.hbrush)
    delete(handles.drawingroi.hbrush);
    handles.drawingroi = rmfield(handles.drawingroi, 'hbrush');
end
if isfield(handles, 'drawingroi') && isfield(handles.drawingroi, 'brushmask')
    handles.drawingroi = rmfield(handles.drawingroi, 'brushmask');
end

guidata(hObject, handles);
updateroitable(hObject)
