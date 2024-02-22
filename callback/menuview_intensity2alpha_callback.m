function menuview_intensity2alpha_callback(hObject, ~)
% slider_alpha_callback is an internal function of fMROI.
%
% Syntax:
%   slider_alpha_callback(hObject, ~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

handles = guidata(hObject);
i = handles.table_selectedcell(1);

for j = 1:3

    cdata = handles.ax{i,j}.d.CData;
    adata = handles.ax{i,j}.d.AlphaData;

    if max(cdata(logical(adata))) > min(logical(adata))
        alpha = (cdata - min(cdata(logical(adata))))/...
            (max(cdata(logical(adata))) - min(cdata(logical(adata))));
        alpha = alpha.*adata;
        set(handles.ax{i,j}.d,'AlphaData',alpha)
    end
end

guidata(hObject, handles);