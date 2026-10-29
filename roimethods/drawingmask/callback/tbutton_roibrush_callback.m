function tbutton_roibrush_callback(hObject,~)
% tbutton_roibrush_callback is an internal function of fMROI.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 28/10/2026, peres.asc@gmail.com

global st
handles = guidata(hObject);

if handles.tbutton_brushroidraw.Value

    set(handles.tbutton_brushroidraw,'BackgroundColor','r')
    
    if isfield(handles, 'drawingroi') &&...
            isfield(handles.drawingroi,'hroi') &&...
            ishandle(handles.drawingroi.hroi)
        delete(handles.drawingroi.hroi)
    end

    if isfield(handles, 'drawingroi') &&...
            isfield(handles.drawingroi,'hbrush') &&...
            ishandle(handles.drawingroi.hbrush)
        delete(handles.drawingroi.hbrush)
    end

    wroi = get(handles.popup_workingroi,'Value')-1; % select the ROI that will be updated
    selaxis = get(handles.popup_workingaxes,'Value'); % select the axis to draw
    selimg = handles.table_selectedcell(1); % Image selected as template
    
    listimgdata = getimgnamelist(hObject);
    st.roisrcname = listimgdata{selimg};

    if ~wroi % creates the image matrix of the new ROI and fill it with zeros        
        datalut = get(handles.table_roilut,'Data');
        
        if  isempty(datalut{1,1})
            roi_idx = [];
        else
            roi_idx = cellfun(@uint16,datalut(:,1));
        end

        srcvol = st.vols{selimg}.private.dat(:,:,:);
        roi = uint16(zeros(size(srcvol)));

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
        
        listimgdata = get(handles.table_listimg,'Data');
        ucidx = find(contains(listimgdata(:,3),'roi_under-construction'), 1); % Image selected as template
        evData.Indices = [ucidx,3];

        guidata(hObject, handles);
        table_listimg_selcallback(hObject, evData)
        handles = guidata(hObject);

        st.vols{ucidx}.clim = [0 double(datalut{end,1})];
        
        %--------------------------------------------------------------------------
        % Generate handles.imgprop fields

        imgmin_str = sprintf('%0.2g',st.vols{ucidx}.clim(1));
        imgmin_str(imgmin_str=='+')=[];

        imgmax_str = sprintf('%0.2g',st.vols{ucidx}.clim(2));
        imgmax_str(imgmax_str=='+')=[];

        handles.imgprop(ucidx).imgmin_str = imgmin_str;
        handles.imgprop(ucidx).imgmax_str = imgmax_str;


        guidata(hObject, handles);
        updateuicontrols(hObject,ucidx)
        slider_maxcolor_callback(hObject)
        handles = guidata(hObject);
    end

    listimgdata = get(handles.table_listimg,'Data');
    ucidx = find(contains(listimgdata(:,3),'roi_under-construction'), 1);
    if isempty(ucidx)
        ucidx = find(~cellfun(@isempty,st.vols), 1, 'last');
    end
    wroi = get(handles.popup_workingroi,'Value')-1;
    datalut = get(handles.table_roilut,'Data');

    slices = getslices(st, ucidx);
    mask2d = slices{selaxis};

    if ~isfield(handles, 'drawingroi')
        handles.drawingroi = struct();
    end
    handles.drawingroi.brushmask = mask2d;
    handles.drawingroi.selaxis = selaxis;
    handles.drawingroi.wroi = wroi;
    handles.drawingroi.ucidx = ucidx;

    % Build overlay RGB and Alpha
    overlay_rgb = zeros(size(mask2d, 1), size(mask2d, 2), 3);
    alpha2d = zeros(size(mask2d));
    alphavalue = handles.imgprop(ucidx).alpha;
    if isempty(alphavalue) || alphavalue == 0
        alphavalue = 0.5;
    end

    for k = 1:size(datalut, 1)
        k_val = datalut{k, 1};
        if iscell(k_val), k_val = k_val{1}; end
        r_k = datalut{k, 3}; if ischar(r_k), r_k = str2double(r_k); end
        g_k = datalut{k, 4}; if ischar(g_k), g_k = str2double(g_k); end
        b_k = datalut{k, 5}; if ischar(b_k), b_k = str2double(b_k); end
        k_color = double([r_k, g_k, b_k]) / 255;
        k_mask = (mask2d == k_val);
        if any(k_mask(:))
            overlay_rgb(:,:,1) = overlay_rgb(:,:,1) + k_color(1) * k_mask;
            overlay_rgb(:,:,2) = overlay_rgb(:,:,2) + k_color(2) * k_mask;
            overlay_rgb(:,:,3) = overlay_rgb(:,:,3) + k_color(3) * k_mask;
            alpha2d(k_mask) = alphavalue;
        end
    end

    r_w = datalut{wroi, 3}; if ischar(r_w), r_w = str2double(r_w); end
    g_w = datalut{wroi, 4}; if ischar(g_w), g_w = str2double(g_w); end
    b_w = datalut{wroi, 5}; if ischar(b_w), b_w = str2double(b_w); end
    active_color = double([r_w, g_w, b_w]) / 255;

    handles.drawingroi.overlay_rgb = overlay_rgb;
    handles.drawingroi.active_color = active_color;

    handles.drawingroi.hbrush = image('Parent', handles.ax{1, selaxis}.ax, ...
        'CData', overlay_rgb, 'AlphaData', alpha2d, ...
        'HitTest', 'off', 'PickableParts', 'none');

    uistack(handles.ax{1, selaxis}.d, 'bottom');
    if isfield(handles.ax{1, selaxis}, 'lx') && ishandle(handles.ax{1, selaxis}.lx)
        uistack(handles.ax{1, selaxis}.lx, 'top');
    end
    if isfield(handles.ax{1, selaxis}, 'ly') && ishandle(handles.ax{1, selaxis}.ly)
        uistack(handles.ax{1, selaxis}.ly, 'top');
    end

    guidata(hObject, handles);
    draw_slices(hObject);
    handles = guidata(hObject);

    for i = 1:3
        set(handles.ax{1,i}.ax,'ButtonDownFcn', @axesdrawing_buttondownfcn_callback)
    end
    set(handles.fig,'windowbuttonmotionfcn',@axesdrawing_buttondownfcn_callback)

else
    set(handles.tbutton_brushroidraw,'BackgroundColor',[.94,.94,.94])
    if isfield(handles, 'drawingroi') && isfield(handles.drawingroi, 'hbrush') && ishandle(handles.drawingroi.hbrush)
        delete(handles.drawingroi.hbrush);
        handles.drawingroi = rmfield(handles.drawingroi, 'hbrush');
    end
    for i = 1:3
        set(handles.ax{1,i}.ax,'ButtonDownFcn', @axes_buttondownfcn_callback)
    end
    set(handles.fig,'windowbuttonmotionfcn',@mousemove)
    guidata(hObject, handles);
    draw_slices(hObject);
    handles = guidata(hObject);
end

guidata(hObject,handles);