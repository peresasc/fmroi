function popup_colormap_callback(hObject, ~)
% popup_colormap_callback is an internal function of fMROI.
%
% Syntax:
%   popup_colormap_callback(hObject, ~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 28/10/2026, peres.asc@gmail.com

global st
handles = guidata(hObject);

v = get(handles.popup_colormap,'Value');
s = get(handles.popup_colormap,'String');
n = handles.table_selectedcell(1);
cmap = s{v};



switch lower(cmap)    
    case 'custom'
        [fn, pn, idx] = uigetfile({'*.txt';'*.mat';'*.*'},'Select a RGB colormap file (nx3)');
        if idx == 0
            return
        end
        [~,~,ext] = fileparts(fn);
        
        if strcmpi(ext,'.mat')
            auxcmap = load(fullfile(pn,fn));
            auxfield = fieldnames(auxcmap);
            cmap = auxcmap.(auxfield{1});
        else            
           cmap = load(fullfile(pn,fn));            
        end
        
        
    case 'colorlut'
        [fn, pn, idx] = uigetfile({'*.txt';'*.mat';'*.*'},'Select a Color LUT file');
        if idx == 0
            return
        end
                
        imgidx = unique(st.vols{n}.private.dat(:));
        
        [origcmap,mapidx] = lut2colormap(fullfile(pn,fn));
        [cmap,~] = selectlutcolormap(imgidx,mapidx,origcmap);
        
        
%         lutpath = '/media/andre/data/data_transfer/maismemoria/scripts/tables/FreeSurferColorLUT.txt';
        
        
end

if ischar(cmap)
    try
        cmap_matrix = feval(cmap, 256);
    catch
        cmap_matrix = gray(256);
    end
else
    cmap_matrix = cmap;
end

handles.imgprop(n).cmap = cmap_matrix;
handles.imgprop(n).colormap = v;

guidata(hObject, handles);

draw_slices(hObject);