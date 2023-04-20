function tbutton_roipen_callback(hObject,~)

global st
handles = guidata(hObject);

if hObject.Value
    
    if isfield(handles, 'drawingroi') &&...
            isfield(handles.drawingroi,'hroi') &&...
            ishandle(handles.drawingroi.hroi)
        delete(handles.drawingroi.hroi)
    end
    

    wroi = get(handles.popup_workingroi,'Value')-1; % select the ROI that will be updated
    selaxis = get(handles.popup_workingaxes,'Value'); % select the axis to draw
    selimg = handles.table_selectedcell(1); % Image selected as template
    himg = handles.ax{selimg,selaxis}.d; % 2D data handle from the selected slice
    
    listimgdata = getimgnamelist(hObject);
    st.roisrcname = listimgdata{selimg};

    if ~wroi % creates the image matrix of the new ROI and fill it with zeros        
        datalut = get(handles.table_roilut,'Data');
        roi_idx = cell2mat(datalut(:,1));

        srcvol = st.vols{selimg}.private.dat(:,:,:);
        roi = zeros(size(srcvol));

        if isfield(st,'roimasks') && ~isempty(roi_idx)
            st.roimasks{end+1} = roi;
        else
            st.roimasks{1} = roi;
        end

        guidata(hObject, handles);
        updateroitable(hObject)
        handles = guidata(hObject);

        datalut = get(handles.table_roilut,'Data');
        set(handles.popup_workingroi,'String',[{'new'};datalut(:,2)])
        set(handles.popup_workingroi,'Value',size(datalut,1)+1);
    end

    n_image = find(~cellfun(@isempty,st.vols), 1, 'last');
    for i = 1:3
        set(handles.ax{n_image,i}.ax,'ButtonDownFcn', @axesdrawing_buttondownfcn_callback)
        set(handles.fig,'windowbuttonmotionfcn',@axesdrawing_buttondownfcn_callback)
        
    end

else
    n_image = find(~cellfun(@isempty,st.vols), 1, 'last');
    for i = 1:3
        set(handles.ax{n_image,i}.ax,'ButtonDownFcn', @axes_buttondownfcn_callback)
        set(handles.fig,'windowbuttonmotionfcn',@mousemove)
    end
end

guidata(hObject,handles);