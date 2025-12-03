function listener_maxthrs_callback(~, eventdata, hObject)
% listener_maxthrs_callback is an internal function of fMROI.
%
% Syntax:
%   listener_maxthrs_callback(~, eventdata, hObject)
%
% Inputs:
%     hObject: handle of the figure that contains the fMROI main window.
%   eventdata: conveys information about changes or actions that occurred
%              within the slider_maxthrs.
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

maxthrs_pos1 = handles.slider_maxthrs.Position(1)+arrowsz +...
    value*(handles.slider_maxthrs.Position(3)-2*arrowsz) -...
    handles.edit_maxthrsupdate.Position(3)/2;

maxthrs_pos = get(handles.edit_maxthrsupdate,'Position');
maxthrs_pos(1) = maxthrs_pos1;

set(handles.edit_maxthrsupdate,'String', imgthrs_str,...
    'Position',maxthrs_pos);