function pbutton_savescrsht_callback(hObject, ~)
% pbutton_savescrsht_callback is an internal function of fMROI.
%
% Syntax:
%   pbutton_savescrsht_callbackt(hObject,~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2023, peres.asc@gmail.com
% Last update: Andre Peres, 22/08/2023, peres.asc@gmail.com

handles = guidata(hObject);

v = get(handles.popup_scrshtmode,'Value');
s = get(handles.popup_scrshtmode,'String');
scrshtmode = s{v};

switch lower(scrshtmode)
    case 'axes'
        save_axes(hObject)

    case 'multi-slice'
        save_multislices(hObject)
    
    case 'mosaic'
        save_mosaic(hObject)
end