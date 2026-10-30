function pbutton_roicleardaw_callback(hObject,~)
% pbutton_roicleardaw_callback is an internal function of fMROI.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 28/10/2026, peres.asc@gmail.com

handles = guidata(hObject);

if isfield(handles, 'drawingroi')
    if isfield(handles.drawingroi,'hroi') && ishandle(handles.drawingroi.hroi)
        delete(handles.drawingroi.hroi)
    end
    if isfield(handles.drawingroi,'hbrush') && ishandle(handles.drawingroi.hbrush)
        delete(handles.drawingroi.hbrush)
        handles.drawingroi = rmfield(handles.drawingroi, 'hbrush');
    end
    if isfield(handles.drawingroi,'brushmask')
        handles.drawingroi = rmfield(handles.drawingroi, 'brushmask');
    end
    guidata(hObject,handles);
    draw_slices(hObject);
end