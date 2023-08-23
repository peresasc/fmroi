function radio_slices_callback(hObject,~)
% radio_slices_callback is an internal function of fMROI.
%
% Syntax:
%   radio_slices_callback(hObject,~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2023, peres.asc@gmail.com
% Last update: Andre Peres, 23/08/2023, peres.asc@gmail.com

handles = guidata(hObject);

if handles.radio_slices(1).Value
    for i = 1:3
        set(handles.edit_slices2save(i),'Enable','off')
    end
else
    for i = 1:3
        set(handles.edit_slices2save(i),'Enable','on')
    end
end

guidata(hObject,handles)
