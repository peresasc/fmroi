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
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

global st
handles = guidata(hObject);

v = get(handles.popup_colormap,'Value');
s = get(handles.popup_colormap,'String');
n = handles.table_selectedcell(1);
cmap = s{v};

cmin = handles.imgprop(n).mincolor;
cmax = handles.imgprop(n).maxcolor;

     
cmin = cmin*(st.vols{n}.clim(2)-st.vols{n}.clim(1))+...
            st.vols{n}.clim(1);
        
cmax = cmax*(st.vols{n}.clim(2)-st.vols{n}.clim(1))+...
            st.vols{n}.clim(1);

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

for i = 1:3
    colormap(handles.ax{n,i}.ax,cmap)
    handles.ax{n,i}.ax.CLim = [cmin cmax];
end


c = gettruecolor(handles.ax{n,1}.d.CData,st.vols{n}.private.dat(:,:,:),handles.ax{n,1}.ax.Colormap);
handles.ax{n,4}.d.CData = c;
handles.imgprop(n).colormap = v;

guidata(hObject, handles);