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
hpos = get(hObject,'Position');

value = get(eventdata.AffectedObject, 'Value');
set(handles.edit_slicealphaupdate,'String',...
    num2str(round(value*100)/100),'Position',...
    [(value*.56+.22),...
    hpos(2)+hpos(4),...
    0.14,...
    0.02]);