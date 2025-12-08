function listener_mincolor_callback(~, eventdata, hObject)
% listener_mincolor_callback is an internal function of fMROI.
%
% Syntax:
%   listener_mincolor_callback(~, eventdata, hObject)
%
% Inputs:
%     hObject: handle of the figure that contains the fMROI main window.
%   eventdata: conveys information about changes or actions that occurred
%              within the slider_mincolor.
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

mincolor_pos1 = handles.slider_mincolor.Position(1)+arrowsz +...
    value*(handles.slider_mincolor.Position(3)-2*arrowsz) -...
    handles.edit_mincolorupdate.Position(3)/2;

mincolor_pos = get(handles.edit_mincolorupdate,'Position');
mincolor_pos(1) = mincolor_pos1;

set(handles.edit_mincolorupdate,'String', imgthrs_str,...
    'Position',mincolor_pos);