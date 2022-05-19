function pbutton_imgup_callback(hObject, ~)
% pbutton_imgup_callback is an internal function of fMROI.
%
% Syntax:
%   pbutton_imgup_callback(hObject, ~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

global st
handles = guidata(hObject);
n = handles.table_selectedcell(1);

if n ~= 1
    handles.table_selectedcell(1) = n-1;
    %----------------------------------------------------------------------
    % change the position of the image name in the table_listimg

    tdata = get(handles.table_listimg,'Data');
    rows = 1:size(tdata,1);
    newrows = rows;
    newrows(n-1) = rows(n);
    newrows(n) = rows(n-1);
    tdata = tdata(newrows,:);
    
    set(handles.table_listimg,'Data', tdata);
    
    if ~get(handles.tbutton_lcsrcsel,'Value')
        guidata(hObject,handles);
        imgnamelist = getimgnamelist(hObject);
        set(handles.popup_lcmask,'String',imgnamelist)
        guidata(hObject, handles);
    end
    
    %----------------------------------------------------------------------
    % change the image properties of the axes that are being permuted
    imgprop0 = handles.imgprop(n-1);
    handles.imgprop(n-1) = handles.imgprop(n);
    handles.imgprop(n) = imgprop0;
    
    %----------------------------------------------------------------------
    % update the color of the axes that are being permuted
    for curr_img = n-1:n
        v = handles.imgprop(curr_img).colormap;
        s = get(handles.popup_colormap,'String');
        
        cmap = s{v};
        
        
        if strcmp(cmap,'custom')
        else
            for i = 1:3
                colormap(handles.ax{curr_img,i}.ax,cmap)
            end
        end
        
        c = gettruecolor(handles.ax{curr_img,1}.d.CData,st.vols{curr_img}.private.dat(:,:,:),handles.ax{curr_img,1}.ax.Colormap);
        handles.ax{curr_img,4}.d.CData = c;
        handles.imgprop(curr_img).colormap = v;
    end
    
    guidata(hObject, handles);
    
    %----------------------------------------------------------------------
    % change the roipath FaceAlpha of the axes that are being permuted
    if isfield(handles.ax{n-1,4},'roipatch') || isfield(handles.ax{n,4},'roipatch')
        if isfield(handles.ax{n-1,4},'roipatch') && isfield(handles.ax{n,4},'roipatch')
            roipatch0 = handles.ax{n-1,4}.roipatch;
            handles.ax{n-1,4}.roipatch = handles.ax{n,4}.roipatch;
            handles.ax{n,4}.roipatch = roipatch0;
        
        elseif isfield(handles.ax{n-1,4},'roipatch')
            handles.ax{n,4}.roipatch = handles.ax{n-1,4}.roipatch;
            handles.ax{n-1,4} = rmfield(handles.ax{n-1,4},'roipatch');
        
        else
            handles.ax{n-1,4}.roipatch = handles.ax{n,4}.roipatch;
            handles.ax{n,4} = rmfield(handles.ax{n,4},'roipatch');
        end
    end
    
    %----------------------------------------------------------------------
    % change the data position in the st structure
    vol0 = st.vols{n-1};
    st.vols{n-1} = st.vols{n};
    st.vols{n} = vol0;
    
    %----------------------------------------------------------------------
    % Makes the updates in the sliser_thrs, slider_alpha and popup_colormap
    
    evData.Indices = handles.table_selectedcell;
    
    guidata(hObject, handles);
    table_listimg_selcallback(hObject, evData)
    handles = guidata(hObject);
    
    %----------------------------------------------------------------------
    % Redraw the slices
    draw_slices(hObject)
    
    handles.table_selectedcell(1) = n;
    
    evData.Indices = handles.table_selectedcell;
    guidata(hObject, handles);
    table_listimg_selcallback(hObject, evData)
    handles = guidata(hObject);
    
    popup_colormap_callback(hObject)
    
    
    handles.table_selectedcell(1) = n-1;
    
    evData.Indices = handles.table_selectedcell;
    guidata(hObject, handles);
    table_listimg_selcallback(hObject, evData)
    handles = guidata(hObject);
    
    popup_colormap_callback(hObject)
    
    
end

guidata(hObject, handles);