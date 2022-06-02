function img2mask_gui(hObject)
% img2mask_gui is a internal function of fMROI. It creates the panel
% and uicontrols for calling img2mask function.
%
% Syntax:
%   img2mask_gui(hObject)
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
% creates the text for source image
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

guidata(hObject,handles)