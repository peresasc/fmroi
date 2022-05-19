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
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

global st
handles = guidata(hObject);

n_image = find(~cellfun(@isempty,st.vols), 1, 'last');
n = handles.table_selectedcell(1);

if ~isempty(n_image)
    for i = 1:3
        if n == n_image && n ~= 1
            handles.ax{n-1,i}.lx = handles.ax{n,i}.lx;
            handles.ax{n-1,i}.ly = handles.ax{n,i}.ly;
            set(handles.ax{n-1,i}.lx,'Parent',handles.ax{n-1,i}.ax)
            set(handles.ax{n-1,i}.ly,'Parent',handles.ax{n-1,i}.ax)
        end
        delete(handles.ax{n,i}.ax)
    end
    
    if isfield(handles.ax{n,4},'roipatch')
        delete(handles.ax{n,4}.roipatch)
    end
    
    delete(handles.ax{n,4}.d)
    
    handles.ax(n,:)=[];
    handles.imgprop(n)=[];
    st.vols(n)=[];
    st.vols{end+1}=[];
    
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
    end
    
    if contains(delfilename,'roi_under-construction')
        st = rmfield(st,'roimasks');
        set(handles.table_roilut,'Data',cell(1,6));
        
        if get(handles.tbutton_lcsrcsel,'Value')
            imgnamelist = get(handles.table_roilut,'Data');
            set(handles.popup_lcmask,'String',imgnamelist(:,2))
        end
    end
    
    guidata(hObject, handles);
end