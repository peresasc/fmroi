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
        pexp = find(imgmax_str=='e');
        if isempty(pexp)
            imgmax_alg = imgmax_str;
            imgmax_exp = '';
        else
            imgmax_alg = imgmax_str(1:pexp-1);
            imgmax_exp = imgmax_str(pexp:end);
            imgmax_exp(imgmax_exp=='+')=[];
        end

%         alphamin_str = num2str(handles.slider_alpha.Min);
%         alphamax_str = num2str(handles.slider_alpha.Max);
%         renderalphamin_str = num2str(handles.slider_roialpha.Min);
%         renderalphamax_str = num2str(handles.slider_roialpha.Max);

%         handles.imgprop(ucidx).viewslices = 1;
%         handles.imgprop(ucidx).viewrender = 0;
%         handles.imgprop(ucidx).colormap = v;
%         handles.imgprop(ucidx).roicolor = 1;

%         handles.imgprop(ucidx).minthrs = handles.slider_minthrs.Min;
%         handles.imgprop(ucidx).maxthrs = handles.slider_maxthrs.Max;
%         handles.imgprop(ucidx).alpha = handles.slider_alpha.Max;
%         handles.imgprop(ucidx).roialpha = handles.slider_roialpha.Max;
%         handles.imgprop(ucidx).mincolor = handles.slider_mincolor.Min;
%         handles.imgprop(ucidx).maxcolor = handles.slider_maxcolor.Max;

%         handles.imgprop(ucidx).alphamin_str = alphamin_str;
%         handles.imgprop(ucidx).alphamax_str = alphamax_str;
%         handles.imgprop(ucidx).renderalphamin_str = renderalphamin_str;
%         handles.imgprop(ucidx).renderalphamax_str = renderalphamax_str;
        handles.imgprop(ucidx).imgmin_str = imgmin_str;
        handles.imgprop(ucidx).imgmax_alg = imgmax_alg;
        handles.imgprop(ucidx).imgmax_exp = imgmax_exp;


        guidata(hObject, handles);
        updateuicontrols(hObject,ucidx)
        slider_maxcolor_callback(hObject)
        handles = guidata(hObject);
    end

    ucidx = find(~cellfun(@isempty,st.vols), 1, 'last');
    for i = 1:3
        set(handles.ax{ucidx,i}.ax,'ButtonDownFcn', @axesdrawing_buttondownfcn_callback)
        set(handles.fig,'windowbuttonmotionfcn',@axesdrawing_buttondownfcn_callback)
        
    end

else
    ucidx = find(~cellfun(@isempty,st.vols), 1, 'last');
    for i = 1:3
        set(handles.ax{ucidx,i}.ax,'ButtonDownFcn', @axes_buttondownfcn_callback)
        set(handles.fig,'windowbuttonmotionfcn',@mousemove)
    end
end

guidata(hObject,handles);