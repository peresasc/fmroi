function drawingmask_gui(hObject)
% regiongrowingmask_gui is a internal function of fMROI. It creates the
% panel and uicontrols for calling regiongrowingmask function.
%
% Syntax:
%   regiongrowingmask_gui(hObject)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

handles = guidata(hObject);
set(handles.pbutton_findmax,'Enable','off')
set(handles.pbutton_roi,'Enable','off')

if isfield(handles, 'drawingroi') &&...
        isfield(handles.drawingroi,'hroi') &&...
        ishandle(handles.drawingroi.hroi)
    delete(handles.drawingroi.hroi)
end

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

   
%--------------------------------------------------------------------------
% creates the text for working ROI dropdown menu
handles.text_workingroi = uicontrol(handles.panel_roimethod, 'Style', 'text',...
            'Units', 'normalized', 'String', 'Select the working ROI:',...
            'BackgroundColor', 'w', 'FontSize', 9,...
            'HorizontalAlignment', 'left',...
            'Position', [0.01, 0.70, 0.47, 0.1]);

%--------------------------------------------------------------------------
% creates the working ROI dropdown menu
handles.popup_workingroi = uicontrol(handles.panel_roimethod, 'Style', 'popup',...
    'Units', 'normalized','Position', [0.01, 0.62, 0.47, 0.1],...
    'background','w');

datalut = get(handles.table_roilut,'Data');
set(handles.popup_workingroi,'String',[{'new'};datalut(:,2)])

%--------------------------------------------------------------------------
% creates the text for working axis dropdown menu
handles.text_workingaxis = uicontrol(handles.panel_roimethod, 'Style', 'text',...
            'Units', 'normalized', 'String', 'Select the working axis:',...
            'BackgroundColor', 'w', 'FontSize', 9,...
            'HorizontalAlignment', 'left',...
            'Position', [0.01, 0.48, 0.47, 0.1]); 

%--------------------------------------------------------------------------
% creates the working axis dropdown menu
handles.popup_workingaxes = uicontrol(handles.panel_roimethod, 'Style', 'popup',...
    'Units', 'normalized','Position', [0.01, 0.40, 0.47, 0.1],...
    'background','w','String',{'Axial';'Coronal';'Sagittal'});

%--------------------------------------------------------------------------
% creates the text for drawing method popupmenu
handles.text_drawingmeth = uicontrol(handles.panel_roimethod,...
            'Style','text','Units','normalized',...
            'String','Select the drawing method:','BackgroundColor','w',...
            'FontSize', 9,'HorizontalAlignment', 'left',...
            'Position', [0.52, 0.70, 0.47, 0.1]);

%--------------------------------------------------------------------------
% creates the drawing method dropdown menu
handles.popup_drawmethod = uicontrol(handles.panel_roimethod, 'Style', 'popup',...
    'Units', 'normalized','Position', [0.52, 0.62, 0.47, 0.1],...
    'background','w','String',{'brush';'closed_shape'},...
    'Callback',@popup_drawmethod_callback);

guidata(hObject,handles)
popup_drawmethod_callback(hObject)
handles = guidata(hObject);


guidata(hObject,handles)