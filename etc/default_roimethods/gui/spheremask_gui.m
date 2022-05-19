function spheremask_gui(hObject)
% spheremask_gui is a internal function of fMROI. It creates the panel
% and uicontrols for calling spheremask function.
%
% Syntax:
%   spheremask_gui(hObject)
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

handles.text_roisourceimage = uicontrol(handles.panel_roimethod, 'Style', 'text',...
            'Units', 'normalized', 'String', ['Source image: ' imgname],...
            'BackgroundColor', 'w', 'FontSize', 9,...
            'HorizontalAlignment', 'left','Position', [0.01, 0.76, 0.98, 0.2]);

%--------------------------------------------------------------------------
% creates the Radio Button Group in panel_roi  

handles.buttongroup_spheremasktype = uibuttongroup(handles.panel_roimethod,...
    'BackgroundColor', 'w', 'Units', 'normalized',...
    'Position', [0.01, 0.01, 0.35, 0.74]);
%--------------------------------------------------------------------------
% creates the spheremasktype radio button radius
handles.radio_sphereradius = uicontrol(...
    handles.buttongroup_spheremasktype, 'Style', 'radiobutton',...
    'Units', 'normalized','Position', [0.01, 0.60, 0.98, 0.34],...
    'String','radius', 'BackgroundColor', 'w');

%--------------------------------------------------------------------------
% creates the spheremasktype radio button volume
handles.radio_spherevolume = uicontrol(...
    handles.buttongroup_spheremasktype, 'Style', 'radiobutton',...
    'Units', 'normalized','Position', [0.01, 0.10, 0.98, 0.34],...
    'String','nvoxels', 'BackgroundColor', 'w');

%--------------------------------------------------------------------------
% creates the text for radius/volume in voxels
handles.text_roiradius = uicontrol(handles.panel_roimethod, 'Style', 'text',...
            'Units', 'normalized', 'String', 'radius or N voxels: ',...
            'BackgroundColor', 'w', 'FontSize', 9,...
            'HorizontalAlignment', 'right','Position', [0.45, 0.01, 0.20, 0.35]);
        
%--------------------------------------------------------------------------
% creates the edit text for radius/volume in voxels
handles.edit_roiradius = uicontrol(handles.panel_roimethod, 'Style', 'edit',...
            'Units', 'normalized', 'String', '3',...
            'BackgroundColor', 'w', 'FontSize', 11,...
            'HorizontalAlignment', 'left','Position', [0.67, 0.01, 0.32, 0.35]);

guidata(hObject,handles)