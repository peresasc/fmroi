function listener_minthrs_callback(~, eventdata, hObject)
% listener_minthrs_callback is an internal function of fMROI.
%
% Syntax:
%   listener_minthrs_callback(~, eventdata, hObject)
%
% Inputs:
%     hObject: handle of the figure that contains the fMROI main window.
%   eventdata: conveys information about changes or actions that occurred
%              within the slider_minthrs.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

global st
handles = guidata(hObject);
n = handles.table_selectedcell(1);
hpos = get(hObject,'Position');
value = get(eventdata.AffectedObject, 'Value');

thrs = value*(st.vols{n}.clim(2)-st.vols{n}.clim(1))+...
            st.vols{n}.clim(1);
        
imgthrs_str = sprintf('%0.2g',thrs);
imgthrs_str(imgthrs_str=='+')=[];

arrowsz = 0.055; % sliders arrow buttons width

minthrs_pos1 = handles.slider_minthrs.Position(1)+arrowsz +...
    value*(handles.slider_minthrs.Position(3)-2*arrowsz) -...
    handles.edit_minthrsupdate.Position(3)/2;

minthrs_pos = get(handles.edit_minthrsupdate,'Position');
minthrs_pos(1) = minthrs_pos1;

set(handles.edit_minthrsupdate,'String',imgthrs_str,...
    'Position',minthrs_pos);