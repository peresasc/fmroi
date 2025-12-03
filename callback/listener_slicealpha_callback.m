function listener_slicealpha_callback(~, eventdata, hObject)
% listener_slicealpha_callback is an internal function of fMROI.
%
% Syntax:
%   listener_slicealpha_callback(~, eventdata, hObject)
%
% Inputs:
%     hObject: handle of the figure that contains the fMROI main window.
%   eventdata: conveys information about changes or actions that occurred
%              within the slider_slicealpha.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

handles = guidata(hObject);
value = get(eventdata.AffectedObject,'Value');

arrowsz = 0.055; % sliders arrow buttons width

alpha_pos1 = handles.slider_alpha.Position(1)+arrowsz +...
    value*(handles.slider_alpha.Position(3)-2*arrowsz) -...
    handles.edit_slicealphaupdate.Position(3)/2;

alpha_pos = get(handles.edit_slicealphaupdate,'Position');
alpha_pos(1) = alpha_pos1;

set(handles.edit_slicealphaupdate,'String',...
    num2str(round(value*100)/100),'Position',alpha_pos);