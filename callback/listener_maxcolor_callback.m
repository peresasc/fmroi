function listener_maxcolor_callback(~, eventdata, hObject)
% listener_maxcolor_callback is an internal function of fMROI.
%
% Syntax:
%   listener_maxcolor_callback(~, eventdata, hObject)
%
% Inputs:
%     hObject: handle of the figure that contains the fMROI main window.
%   eventdata: conveys information about changes or actions that occurred
%              within the slider_maxcolor.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

global st
handles = guidata(hObject);
n = handles.table_selectedcell(1);
value = get(eventdata.AffectedObject, 'Value');

thrs = value*(st.vols{n}.clim(2)-st.vols{n}.clim(1))+...
            st.vols{n}.clim(1);

imgthrs_str = sprintf('%0.2g',thrs);
imgthrs_str(imgthrs_str=='+')=[];

arrowsz = 0.055; % sliders arrow buttons width

maxcolor_pos1 = handles.slider_maxcolor.Position(1)+arrowsz +...
    value*(handles.slider_maxcolor.Position(3)-2*arrowsz) -...
    handles.edit_maxcolorupdate.Position(3)/2;

maxcolor_pos = get(handles.edit_maxcolorupdate,'Position');
maxcolor_pos(1) = maxcolor_pos1;

set(handles.edit_maxcolorupdate,'String', imgthrs_str,...
    'Position',maxcolor_pos);