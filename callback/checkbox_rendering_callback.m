function checkbox_rendering_callback(hObject, ~)
% checkbox_rendering_callback is an internal function of fMROI.
%
% Syntax:
%   checkbox_rendering_callback(hObject, ~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

handles = guidata(hObject);
n = handles.table_selectedcell(1);

handles.imgprop(n).viewrender = get(handles.checkbox_rendering,'Value');
guidata(hObject, handles);

if isfield(handles.ax{n,4},'roipatch')
    if handles.imgprop(n).viewrender
        handles.ax{n,4}.roipatch.Visible = 'on';
    else
        handles.ax{n,4}.roipatch.Visible = 'off';
    end
else
    if handles.imgprop(n).viewrender
        mask = img2mask_caller(hObject);
        draw_isosurface(hObject, mask)
        handles = guidata(hObject);
    end
end

guidata(hObject, handles);