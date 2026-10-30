function pbutton_delete_callback(hObject, ~)
% pbutton_delete_callback is an internal function of fMROI.
%
% Syntax:
%   pbutton_delete_callback(hObject, ~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 28/10/2026, peres.asc@gmail.com

global st
handles = guidata(hObject);

n_image = find(~cellfun(@isempty,st.vols), 1, 'last');
n = handles.table_selectedcell(1);

if ~isempty(n_image)
    if isfield(handles.ax{n,4},'roipatch') && ishandle(handles.ax{n,4}.roipatch)
        delete(handles.ax{n,4}.roipatch)
    end
    
    handles.imgprop(n)=[];
    st.vols(n)=[];
    st.vols{end+1}=[];
    if size(handles.ax, 1) > 1
        handles.ax(n,:)=[];
    end
    
    if isempty(find(~cellfun(@isempty,st.vols), 1, 'last'))
        for i = 1:3
            if isfield(handles.ax{1,i}, 'ax') && ishandle(handles.ax{1,i}.ax)
                delete(handles.ax{1,i}.ax);
            end
        end
        if isfield(handles.ax{1,4}, 'ax') && ishandle(handles.ax{1,4}.ax)
            delete(handles.ax{1,4}.ax);
        end
        handles = rmfield(handles, 'ax');
        
        set(handles.panel_control,'Visible','off')
        set(handles.menuview_showctrlpanel,'Enable','off')
        if isfield(handles, 'axannot')
            delete(handles.axannot)
            handles = rmfield(handles,'axannot');
        end
        guidata(hObject,handles);
    end
    
    tdata = get(handles.table_listimg,'Data');
    delfilename = tdata{n,3};
    tdata(n,:) = [];
    set(handles.table_listimg,'Data',tdata);
    
    if ~get(handles.tbutton_lcsrcsel,'Value')
        guidata(hObject,handles);
        imgnamelist = getimgnamelist(hObject);
        set(handles.popup_lcmask,'String',imgnamelist)
        guidata(hObject, handles);
    end
    
    handles.table_selectedcell(1) = 1;
    
    if isempty(handles.imgprop)
        set(handles.slider_alpha,'value',1)
        set(handles.slider_minthrs,'value',0)
        set(handles.popup_colormap,'value',1)
        
    else
        evData.Indices = handles.table_selectedcell;
        guidata(hObject, handles);
        table_listimg_selcallback(hObject, evData)
        handles = guidata(hObject);
        draw_slices(hObject);
    end
    
    if contains(delfilename,'roi_under-construction')
        st = rmfield(st,'roimasks');
        set(handles.table_roilut,'Data',cell(1,6));

        guidata(hObject, handles);
        popup_roitype_callback(hObject);
        handles = guidata(hObject);
        
        if get(handles.tbutton_lcsrcsel,'Value')
            roinamelist = get(handles.table_roilut,'Data');
            set(handles.popup_lcmask,'String',roinamelist(:,2))
        end
        
    end
    
    guidata(hObject, handles);
end