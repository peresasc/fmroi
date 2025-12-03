function updateroitable(hObject)
% updateroitable is an internal function of fMROI.
%
% Syntax:
%   updateroitable(hObject)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

global st
handles = guidata(hObject);

%--------------------------------------------------------------------------
% Delete the previous roi_under-construction.nii
auxroimasks = st.roimasks; % stores st.roimasks because it is deleted by pbutton_delete_callback
datalut = get(handles.table_roilut,'Data');
listimgdata = get(handles.table_listimg,'Data');
ucidx = find(contains(listimgdata(:,3),'roi_under-construction'), 1);
srcidx = find(contains(listimgdata(:,3),st.roisrcname), 1);

if isempty(auxroimasks)
    if ~isempty(ucidx)
        handles.table_selectedcell(1) = ucidx;
        guidata(hObject, handles);

        pbutton_delete_callback(hObject)
        handles = guidata(hObject);
    end

    %--------------------------------------------------------------------------
    % Change the table_listimg selected row to st.roisrcname

    handles.table_selectedcell(1) = srcidx;
    evData.Indices = handles.table_selectedcell;
    guidata(hObject, handles);
    table_listimg_selcallback(hObject, evData)
    handles = guidata(hObject);

    %--------------------------------------------------------------------------
    % Update table_roilut
else
    %     st.roimasks = auxroimasks; % restore st.roimasks

    ucmask = zeros(size(st.roimasks{1})); % create the under-construction mask
    roimasksidx = cell(length(st.roimasks),1);
    for m = 1:length(st.roimasks)
        auxidx = unique(st.roimasks{m});
        auxidx(auxidx==0) = [];
        roimasksidx{m,1} = auxidx;
        ucmask(logical(st.roimasks{m})) =...
            st.roimasks{m}(logical(st.roimasks{m}));
    end

    %----------------------------------------------------------------------
    % ROIs only with zero elements
    % fill with zero empty cell elements and assigns a new index value
    emptycells = cellfun(@isempty,roimasksidx);
    if nnz(emptycells)
        roimasksidx(emptycells) = {0};
        if nnz(emptycells)
            midx = max(cellfun(@uint16,roimasksidx));
            if isempty(midx)
                midx = 0;
            end
            ept = find(emptycells);
            for i = 1:length(ept)
                roimasksidx{ept(i),1} = midx+i;
            end
        end
    end

    roimidx = cellfun(@uint16,roimasksidx); % roimask indexes
    
    if  isempty(datalut{1,1}) % datalut indexes
        dlutidx = [];
    else
        dlutidx = cellfun(@uint16,datalut(:,1));
    end

    if length(roimidx) > length(dlutidx)
        [tf,~] = ismember(roimidx,dlutidx);
        newidx = find(~tf)';
        if ~isempty(datalut{1,1})
            datalut = [datalut;cell(length(newidx),6)];
        elseif length(newidx)>1
            datalut = [datalut;cell(length(newidx)-1,6)];
        end

        datalut(:,1) = roimasksidx;
        for k = newidx
            datalut{k,2} = ['roi_',num2str(roimidx(k))]; % roi_name
            datalut{k,3} = round(255*rand(1)); % R
            datalut{k,4} = round(255*rand(1)); % G
            datalut{k,5} = round(255*rand(1)); % B
            datalut{k,6} = 0; % Alpha
        end
    elseif length(roimidx) < length(dlutidx)
        [tf,~] = ismember(dlutidx,roimidx);
        delidx = find(~tf)';
        datalut(delidx,:) = [];
    end

    set(handles.table_roilut,'Data',datalut);
    % if get(handles.tbutton_lcsrcsel,'Value')
    %     set(handles.popup_lcmask,'String',datalut)
    % end
    
    if get(handles.tbutton_lcsrcsel,'Value')
        roinamelist = get(handles.table_roilut,'Data');
        set(handles.popup_lcmask,'String',roinamelist(:,2))
    end

    guidata(hObject, handles);

    %--------------------------------------------------------------------------
    % Saving the mask to a nifti image

    filename = fullfile(handles.tmpdir,'roi_under-construction.nii');
    vsrc = spm_vol(st.vols{srcidx}.fname);
    vsrc.fname = filename;
    V = spm_create_vol(vsrc);
    V.pinfo = [1;0;0]; % avoid SPM to rescale the masks
    V = spm_write_vol(V, ucmask);

    %--------------------------------------------------------------------------
    % Display ROI slices

    if isempty(ucidx)
        show_slices(hObject, filename)
        handles = guidata(hObject);
        listimgdata = get(handles.table_listimg,'Data');
        ucidx = find(contains(listimgdata(:,3),'roi_under-construction'), 1);
    end
    %     else
    %         clim0 = st.vols{ucidx}.clim;
    st.vols{ucidx}.private.dat(:,:,:) = ucmask;

    if min(st.vols{ucidx}.private.dat(:)) ~=...
            max(st.vols{ucidx}.private.dat(:))
        st.vols{ucidx}.clim = [min(st.vols{ucidx}.private.dat(:)),...
            max(st.vols{ucidx}.private.dat(:))];
    end

    for k = 1:3
        caxis(handles.ax{ucidx,k}.ax,st.vols{ucidx}.clim);
    end

    %------------------------------------------------------------------
    % Redifinig the max and min color threshold
    imgmin_str = sprintf('%0.2g',st.vols{ucidx}.clim(1));
    imgmin_str(imgmin_str=='+')=[];

    imgmax_str = sprintf('%0.2g',st.vols{ucidx}.clim(2));
    imgmax_str(imgmax_str=='+')=[];
    
    handles.imgprop(ucidx).imgmin_str = imgmin_str;
    handles.imgprop(ucidx).imgmax_str = imgmax_str;

    minthrs0_value = .01; % remove zeros from uc image
    minthrs = (minthrs0_value-st.vols{ucidx}.clim(1))/...
        (st.vols{ucidx}.clim(2)-st.vols{ucidx}.clim(1));

    handles.imgprop(ucidx).minthrs = minthrs;
    handles.imgprop(ucidx).maxthrs = 1;
    handles.imgprop(ucidx).mincolor = 0;
    handles.imgprop(ucidx).maxcolor = 1;


    guidata(hObject, handles);
    updateuicontrols(hObject,ucidx);
    handles = guidata(hObject);

    guidata(hObject, handles)
    draw_slices(hObject)
    %     end
    %     handles = guidata(hObject);

    evData.Indices = [srcidx,3];
    % guidata(hObject, handles);
    table_listimg_selcallback(hObject, evData)
    handles = guidata(hObject);

    %--------------------------------------------------------------------------
    % Display ROI as 3D isosurface

    if ~isempty(ucidx) && handles.imgprop(ucidx).viewrender
        if isfield(handles.ax{ucidx,4},'roipatch')
            delete(handles.ax{ucidx,4}.roipatch)
            handles.ax{ucidx,4} = rmfield(handles.ax{ucidx,4},'roipatch');
        end
        guidata(hObject, handles);
        mask = img2mask_caller(hObject);
        draw_isosurface(hObject, mask)
        handles = guidata(hObject);
    end
end
guidata(hObject, handles);