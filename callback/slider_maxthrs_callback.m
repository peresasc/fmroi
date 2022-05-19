function slider_maxthrs_callback(hObject, ~)
% slider_maxthrs_callback is an internal function of fMROI.
%
% Syntax:
%   slider_maxthrs_callback(hObject, ~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

handles = guidata(hObject);

n = handles.table_selectedcell(1);

handles.imgprop(n).maxthrs = get(handles.slider_maxthrs,'Value');

guidata(hObject, handles)

if handles.imgprop(n).viewrender
    if isfield(handles.ax{n,4},'roipatch')
        delete(handles.ax{n,4}.roipatch)
        handles.ax{n,4} = rmfield(handles.ax{n,4},'roipatch');
    end    
    
    guidata(hObject, handles)
    mask = img2mask_caller(hObject);
    draw_isosurface(hObject, mask)
    handles = guidata(hObject);    
end

guidata(hObject, handles);

draw_slices(hObject)