function cubicmask_gui(hObject)
% cubicmask_gui is a internal function of fMROI. It creates the panel
% and uicontrols for calling cubicmask function.
%
% Syntax:
%   cubicmask_gui(hObject)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

handles = guidata(hObject);
%--------------------------------------------------------------------------
% creates the ROIs Panel
panelroi_pos = [0.01, 0.01, 0.98, 0.87];

handles.panel_roimethod = uipanel(handles.tab_genroi, 'BackgroundColor', 'w', ...
    'Units', 'normalized', 'Position', panelroi_pos, 'Visible', 'on');

%--------------------------------------------------------------------------
guidata(hObject,handles)
imgname = getselectedimgname(hObject);

handles.text_roisrcimagetxt = uicontrol(handles.panel_roimethod, 'Style', 'text',...
            'Units', 'normalized','FontWeight','bold', 'String', 'Source image:',...
            'BackgroundColor', 'w', 'FontSize', 9,...
            'HorizontalAlignment', 'left','Position', [0.01, 0.91, 0.3, .07]);
        
handles.text_roisrcimage = uicontrol(handles.panel_roimethod, 'Style', 'text',...
            'Units', 'normalized', 'String', imgname,...
            'BackgroundColor', 'w', 'FontSize', 9,...
            'HorizontalAlignment', 'left','Position', [0.01, 0.84, 0.98, 0.07]);

%--------------------------------------------------------------------------
% creates the Radio Button Group in panel_roi  

handles.buttongroup_cubicmasktype = uibuttongroup(handles.panel_roimethod,...
    'BackgroundColor', 'w', 'Units', 'normalized',...
    'Position', [0.01, 0.72, 0.48, 0.1]);
%--------------------------------------------------------------------------
% creates the cubicmasktype radio button radius
handles.radio_cubicradius = uicontrol(...
    handles.buttongroup_cubicmasktype, 'Style', 'radiobutton',...
    'Units', 'normalized','Position', [0.08, 0.1, 0.4, 0.8],...
    'String','radius', 'BackgroundColor', 'w');

%--------------------------------------------------------------------------
% creates the cubicmasktype radio button volume
handles.radio_cubicvolume = uicontrol(...
    handles.buttongroup_cubicmasktype, 'Style', 'radiobutton',...
    'Units', 'normalized','Position', [0.52, 0.1, 0.4, 0.8],...
    'String','nvoxels', 'BackgroundColor', 'w');

%--------------------------------------------------------------------------
% creates the text for radius/volume in voxels
handles.text_roiradius = uicontrol(handles.panel_roimethod, 'Style', 'text',...
            'Units', 'normalized', 'String', 'Size (voxels): ',...
            'BackgroundColor', 'w', 'FontSize', 9,...
            'HorizontalAlignment', 'left','Position', [0.01, 0.62, 0.22, 0.07]);
        
%--------------------------------------------------------------------------
% creates the edit text for radius/volume in voxels
handles.edit_roiradius = uicontrol(handles.panel_roimethod, 'Style', 'edit',...
            'Units', 'normalized', 'String', '3',...
            'BackgroundColor', 'w', 'FontSize', 11,...
            'HorizontalAlignment', 'left','Position', [0.23, 0.62, 0.25, 0.08]);

guidata(hObject,handles)