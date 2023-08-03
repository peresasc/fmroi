function contiguousclustering_gui(hObject)
% contiguousclustering_gui is a internal function of fMROI. It creates the
% panel and uicontrols for calling contiguousclustering function.
%
% Syntax:
%   contiguousclustering_gui(hObject)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 03/08/2023, peres.asc@gmail.com

handles = guidata(hObject);
%--------------------------------------------------------------------------
% creates the ROIs Panel
panelroi_pos = [0.01, 0.01, 0.98, 0.87];

handles.panel_roimethod = uipanel(handles.tab_genroi,...
    'BackgroundColor','w','Units','normalized',...
    'Position',panelroi_pos,'Visible','on');

%--------------------------------------------------------------------------
% creates the text for source image
guidata(hObject,handles)
imgname = getselectedimgname(hObject);

handles.text_roisrcimagetxt = uicontrol(handles.panel_roimethod,...
    'Style','text','Units','normalized','String','Source image:',...
    'FontUnits','normalized','FontSize',.7,'FontWeight','bold',...
    'BackgroundColor','w','HorizontalAlignment','left',...
    'Position',[.01,.91,.3,.07]);
        
handles.text_roisrcimage = uicontrol(handles.panel_roimethod,...
    'Style','text','Units','normalized','String', imgname,...
    'FontUnits','normalized','FontSize',.7,'BackgroundColor','w',...
    'HorizontalAlignment','left','Position',[.01,.81,.98,.07]);
        
%--------------------------------------------------------------------------
% creates the text for radius/volume in voxels
handles.text_mincltsz = uicontrol(handles.panel_roimethod,...
    'Style','text','Units','normalized',...
    'String','Min cluster size (voxels):',...
    'FontUnits','normalized','FontSize',.8,'BackgroundColor','w',...
    'HorizontalAlignment','left','Position',[.01,.67,.44,.07]);
        
%--------------------------------------------------------------------------
% creates the edit text for radius/volume in voxels
handles.edit_mincltsz = uicontrol(handles.panel_roimethod,...
    'Style','edit','Units','normalized','String','5',...
    'FontUnits','normalized','FontSize',.7,'BackgroundColor','w',...
    'HorizontalAlignment','left','Position',[.45,.66,.15,.08]);

guidata(hObject,handles)