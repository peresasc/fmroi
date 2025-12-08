function edit_sliderupdate_callback(hObject, ~)
% edit_sliderupdate_callback is an internal function of fMROI.
%
% Syntax:
%   edit_sliderupdate_callback(hObject, ~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

global st
handles = guidata(hObject);
n = handles.table_selectedcell(1);
tag = get(hObject,'Tag');

try
    value = str2double(get(hObject,'String'));
catch
    he = errordlg('Input value must be numeric!','Type Error');
    uiwait(he)
    return
end

if isnan(value)
    he = errordlg('Input value must be numeric!','Type Error');
    uiwait(he)
    return    
end

switch lower(tag)
    case 'edit_minthrsupdate'
        value  = (value-st.vols{n}.clim(1))/...
            (st.vols{n}.clim(2)-st.vols{n}.clim(1));
        
        if value < 0
            value = 0;
        elseif value > 1
            value = 1;
        end
        
        handles.imgprop(n).minthrs = value;
        set(handles.slider_minthrs,'value',value)
        slider_thrs_callback(hObject)
        
    case 'edit_maxthrsupdate'
        value  = (value-st.vols{n}.clim(1))/...
            (st.vols{n}.clim(2)-st.vols{n}.clim(1));
        
        if value < 0
            value = 0;
        elseif value > 1
            value = 1;
        end
        
        handles.imgprop(n).maxthrs = value;
        set(handles.slider_maxthrs,'value',value)
        slider_maxthrs_callback(hObject)
        
    case 'edit_slicealphaupdate'               
        if value < 0
            value = 0;
        elseif value > 1
            value = 1;
        end
        
        handles.imgprop(n).alpha = value;
        set(handles.slider_alpha,'value',value)
        slider_alpha_callback(hObject)
        
    case 'edit_roialphaupdate'        
        if value < 0
            value = 0;
        elseif value > 1
            value = 1;
        end
        
        handles.imgprop(n).roialpha = value;
        set(handles.slider_roialpha,'value',value)
        slider_roialpha_callback(hObject)
        
                
    case 'edit_mincolorupdate'
        value  = (value-st.vols{n}.clim(1))/...
            (st.vols{n}.clim(2)-st.vols{n}.clim(1));
        
        if value < 0
            value = 0;
        elseif value > 1
            value = 1;
        end
        
        handles.imgprop(n).mincolor = value;
        set(handles.slider_mincolor,'value',value)
        slider_mincolor_callback(hObject)
        
    case 'edit_maxcolorupdate'
        value  = (value-st.vols{n}.clim(1))/...
            (st.vols{n}.clim(2)-st.vols{n}.clim(1));
        
        if value < 0
            value = 0;
        elseif value > 1
            value = 1;
        end
        
        handles.imgprop(n).maxcolor = value;
        set(handles.slider_maxcolor,'value',value)
        slider_maxcolor_callback(hObject)
end

set(hObject,'Style','text','Enable','inactive')
guidata(hObject, handles);