function updateuicontrols(hObject,n_image)
% updateuicontrols is an internal function of fMROI that updates the
% objects in the GUI.
%
% Syntax:
%   updateuicontrols(hObject,n_image)
%
% Inputs:
%   hObject: Handle of the figure that contains the fMROI main window.
%   n_image: Index of the image (in the st structure) to be updated.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

global st
handles = guidata(hObject);

currminthrs = handles.imgprop(n_image).minthrs *...
    (st.vols{n_image}.clim(2)-st.vols{n_image}.clim(1)) +...
    st.vols{n_image}.clim(1);
        
currminthrs_str = sprintf('%0.2g',currminthrs);
currminthrs_str(currminthrs_str=='+')=[];

currmaxthrs = handles.imgprop(n_image).maxthrs *...
    (st.vols{n_image}.clim(2)-st.vols{n_image}.clim(1)) +...
    st.vols{n_image}.clim(1);

currmaxthrs_str = sprintf('%0.2g',currmaxthrs);
currmaxthrs_str(currmaxthrs_str=='+')=[];


currmincolor = handles.imgprop(n_image).mincolor *...
    (st.vols{n_image}.clim(2)-st.vols{n_image}.clim(1))+...
    st.vols{n_image}.clim(1);

currmincolor_str = sprintf('%0.2g',currmincolor);
currmincolor_str(currmincolor_str=='+')=[];

currmaxcolor = handles.imgprop(n_image).maxcolor *...
    (st.vols{n_image}.clim(2)-st.vols{n_image}.clim(1))+...
    st.vols{n_image}.clim(1);

currmaxcolor_str = sprintf('%0.2g',currmaxcolor);
currmaxcolor_str(currmaxcolor_str=='+')=[];
%--------------------------------------------------------------------------

set(handles.checkbox_rendering,'value',handles.imgprop(n_image).viewrender)

set(handles.popup_colormap,'value',handles.imgprop(n_image).colormap)
set(handles.popup_roicolor,'value',handles.imgprop(n_image).roicolor)

set(handles.slider_minthrs,'value',handles.imgprop(n_image).minthrs)
set(handles.slider_maxthrs,'value',handles.imgprop(n_image).maxthrs)
set(handles.slider_alpha,'value',handles.imgprop(n_image).alpha)
set(handles.slider_roialpha,'value',handles.imgprop(n_image).roialpha)
set(handles.slider_mincolor,'value',handles.imgprop(n_image).mincolor)
set(handles.slider_maxcolor,'value',handles.imgprop(n_image).maxcolor)

set(handles.edit_minthrs0,'String',handles.imgprop(n_image).imgmin_str)
set(handles.edit_minthrs100,'String',handles.imgprop(n_image).imgmax_str)
set(handles.edit_minthrsupdate,'String',currminthrs_str)

set(handles.edit_maxthrs0,'String',handles.imgprop(n_image).imgmin_str)
set(handles.edit_maxthrs100,'String',handles.imgprop(n_image).imgmax_str)
set(handles.edit_maxthrsupdate,'String',currmaxthrs_str)

set(handles.edit_slicealpha0,'String',handles.imgprop(n_image).alphamin_str)
set(handles.edit_slicealpha100,'String',handles.imgprop(n_image).alphamax_str)
set(handles.edit_slicealphaupdate,'String',sprintf('%0.2g',handles.imgprop(n_image).alpha))

set(handles.edit_roialpha0,'String',handles.imgprop(n_image).renderalphamin_str)
set(handles.edit_roialpha100,'String',handles.imgprop(n_image).renderalphamax_str)
set(handles.edit_roialphaupdate,'String',sprintf('%0.2g',handles.imgprop(n_image).roialpha))

set(handles.edit_mincolor0,'String',handles.imgprop(n_image).imgmin_str)
set(handles.edit_mincolor100,'String',handles.imgprop(n_image).imgmax_str)
set(handles.edit_mincolorupdate,'String',currmincolor_str)

set(handles.edit_maxcolor0,'String',handles.imgprop(n_image).imgmin_str)
set(handles.edit_maxcolor100,'String',handles.imgprop(n_image).imgmax_str)
set(handles.edit_maxcolorupdate,'String',currmaxcolor_str)

guidata(hObject, handles);