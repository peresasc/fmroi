function tbutton_lcsrcsel_callback(hObject,~)
% tbutton_lcsrcsel_callback is an internal function of fMROI.
%
% Syntax:
%   tbutton_lcsrcsel_callback(hObject, ~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

handles = guidata(hObject);

val = get(handles.tbutton_lcsrcsel,'Value');
set(handles.popup_lcmask,'Value',1)

if val
    set(handles.tbutton_lcsrcsel,'String','ROI');
    
    imgnamelist = get(handles.table_roilut,'Data');
    set(handles.popup_lcmask,'String',imgnamelist(:,2))
else
    set(handles.tbutton_lcsrcsel,'String','Image');
    
    guidata(hObject,handles);
    imgnamelist = getimgnamelist(hObject);
    set(handles.popup_lcmask,'String',imgnamelist)
end

guidata(hObject, handles);