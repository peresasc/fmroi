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
% Last update: Andre Peres, 04/08/2023, peres.asc@gmail.com

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
fss = handles.fss; % font size scale
panelroi_pos = [0.01, 0.01, 0.98, 0.87];

handles.panel_roimethod = uipanel(handles.tab_genroi,...
    'Units','normalized','BackgroundColor','w',...
    'Position',panelroi_pos,'Visible', 'on');

%--------------------------------------------------------------------------
% creates the text for source image
guidata(hObject,handles)
imgname = getselectedimgname(hObject);

handles.text_roisrcimagetxt = uicontrol(handles.panel_roimethod,...
    'Style','text','Units','normalized','FontWeight','bold',...
    'String','Source image:','BackgroundColor','w',...
    'FontUnits','normalized','FontSize',fss*.65,...
    'HorizontalAlignment','left','Position',[.01,.9,.98,.1]);

handles.text_roisrcimage = uicontrol(handles.panel_roimethod,...
    'Style','text','Units','normalized','String',imgname,...
    'FontUnits','normalized','FontSize',fss*.65,'BackgroundColor','w',...
    'HorizontalAlignment','left','Position',[.01,.8,.98,.1]);

   
%--------------------------------------------------------------------------
% creates the text for working ROI dropdown menu
handles.text_workingroi = uicontrol(handles.panel_roimethod,...
    'Style','text','Units','normalized','BackgroundColor','w',...
    'String','Working ROI:',...
    'FontUnits','normalized','FontSize',fss*.7,...
    'HorizontalAlignment','left','Position',[.01,.68,.47,.1]);

%--------------------------------------------------------------------------
% creates the working ROI dropdown menu
handles.popup_workingroi = uicontrol(handles.panel_roimethod,...
    'Style','popup','Units','normalized','Position',[.01,.55,.47,.13],...
    'FontUnits','normalized','FontSize',fss*.5,'background','w');

datalut = get(handles.table_roilut,'Data');
set(handles.popup_workingroi,'String',[{'new'};datalut(:,2)])

%--------------------------------------------------------------------------
% creates the text for working axis dropdown menu
handles.text_workingaxis = uicontrol(handles.panel_roimethod,...
    'Style','text','Units','normalized','String','Working axis:',...
    'FontUnits','normalized','FontSize',fss*.7,'BackgroundColor','w',...
    'HorizontalAlignment','left','Position',[.01,.42,.47,.1]); 

%--------------------------------------------------------------------------
% creates the working axis dropdown menu
handles.popup_workingaxes = uicontrol(handles.panel_roimethod,...
    'Style','popup','Units','normalized','Position',[.01,.29,.47,.13],...
    'String',{'Axial';'Coronal';'Sagittal'},...
    'FontUnits','normalized','FontSize',fss*.5,'background','w');

%--------------------------------------------------------------------------
% creates the text for drawing method popupmenu
handles.text_drawingmeth = uicontrol(handles.panel_roimethod,...
    'Style','text','Units','normalized','String','Drawing method:',...
    'FontUnits','normalized','FontSize',fss*.7,'BackgroundColor','w',...
    'HorizontalAlignment','left','Position',[.52,.68,.47,.1]);

%--------------------------------------------------------------------------
% creates the drawing method dropdown menu
handles.popup_drawmethod = uicontrol(handles.panel_roimethod,...
    'Style','popup','Units','normalized','background','w',...
    'String',{'brush';'closed_shape'},...
    'FontUnits','normalized','FontSize',fss*.5,...
    'Position',[.52,.55,.47,.13],'Callback',@popup_drawmethod_callback);

guidata(hObject,handles)
popup_drawmethod_callback(hObject)
handles = guidata(hObject);


guidata(hObject,handles)