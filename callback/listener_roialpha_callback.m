function listener_roialpha_callback(~, eventdata, hObject)
% listener_roialpha_callback is an internal function of fMROI.
%
% Syntax:
%   listener_roialpha_callback(~, eventdata, hObject)
%
% Inputs:
%     hObject: handle of the figure that contains the fMROI main window.
%   eventdata: conveys information about changes or actions that occurred
%              within the slider_roialpha.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

handles = guidata(hObject);
value = get(eventdata.AffectedObject,'Value');

arrowsz = 0.055; % sliders arrow buttons width

roialpha_pos1 = handles.slider_roialpha.Position(1)+arrowsz +...
    value*(handles.slider_roialpha.Position(3)-2*arrowsz) -...
    handles.edit_roialphaupdate.Position(3)/2;

roialpha_pos = get(handles.edit_roialphaupdate,'Position');
roialpha_pos(1) = roialpha_pos1;

set(handles.edit_roialphaupdate,'String', num2str(round(value*100)/100),...
    'Position',roialpha_pos);