function regiongrowingmask_gui(hObject)
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
% Last update: Andre Peres, 03/08/2023, peres.asc@gmail.com

handles = guidata(hObject);
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
imgnamelist = getimgnamelist(hObject);

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
% creates the text for growing method dropdown menu
handles.text_growingmode = uicontrol(handles.panel_roimethod,...
    'Style','text','Units','normalized','String','Growing method:',...
    'FontUnits','normalized','FontSize',fss*.7,'BackgroundColor','w',...
    'HorizontalAlignment','left','Position',[.01,.68,.47,.1]);

%--------------------------------------------------------------------------
% creates the growing method dropdown menu
handles.popup_growingmode = uicontrol(handles.panel_roimethod,...
    'Style','popup','Units','normalized','background','w',...
    'String',[{'ascending'};{'descending'};{'similarity'}],...
    'FontUnits','normalized','FontSize',fss*.5,'Position',[.01,.55,.47,.13]);

%--------------------------------------------------------------------------
% creates the text for number of voxels in the ROI
handles.text_roinvox = uicontrol(handles.panel_roimethod,...
    'Style','text','Units','normalized','String','Size (voxels):',...
    'FontUnits','normalized','FontSize',fss*.7,'BackgroundColor','w',...
    'HorizontalAlignment','left','Position', [0.52, 0.68, 0.47, 0.1]);
        
%--------------------------------------------------------------------------
% creates the edit text for number of voxels in the ROI
handles.edit_roinvox = uicontrol(handles.panel_roimethod,...
    'Style','edit','Units','normalized','String','50',...
    'FontUnits','normalized','FontSize',fss*.7,'BackgroundColor','w',...
    'HorizontalAlignment','left','Position',[.52,.58,.23,.1]);

%--------------------------------------------------------------------------
% creates the 'Auto' checkbox for number of voxels in the ROI
handles.checkbox_autogrowingsize = uicontrol(handles.panel_roimethod,...
    'Style','checkbox','Units','normalized','String','Auto',...
    'FontUnits','normalized','FontSize',fss*.7,'BackgroundColor','w',...
    'Position',[.76,.58,.3,.1],...
    'Callback',@checkbox_autogrowingsize_callback);

%--------------------------------------------------------------------------
% creates the text for the intensity threshold buttongroup
handles.text_growingthrsmeth = uicontrol(handles.panel_roimethod,...
    'Style','text','Units','normalized','String','Threshold method:',...    
    'FontUnits','normalized','FontSize',fss*.7,'BackgroundColor','w',...
    'HorizontalAlignment','left','Position',[.01,.42,.47,.1]);

%--------------------------------------------------------------------------
% creates the intensity threshold dropdown menu
handles.popup_growingthrsmeth = uicontrol(handles.panel_roimethod,...
    'Style','popup','Units','normalized','Position',[.01,.29,.31,.13],...
    'String',[{'None'};{'Seed diff'}],...
    'FontUnits','normalized','FontSize',fss*.5,'background','w',...
    'Callback',@popup_growingthrsmeth_callback);

%--------------------------------------------------------------------------
% creates the intensity threshold edit text
handles.edit_growingthrsmeth = uicontrol(handles.panel_roimethod,...
    'Style','edit','Units','normalized','String','inf',...
    'FontUnits','normalized','FontSize',fss*.7,'BackgroundColor','w',...
    'HorizontalAlignment','left','Position',[.325,.32,.145,0.1],...
    'Enable','off');

%--------------------------------------------------------------------------
% creates the text for growingpremask popup in panel_roi
handles.text_growingpremask = uicontrol(handles.panel_roimethod,...
    'Style','text','Units','normalized','BackgroundColor','w',...
    'String','Premask method:',...
    'FontUnits','normalized','FontSize',fss*.7,...
    'HorizontalAlignment','left','Position',[.52,.42,.47,.1]);

%--------------------------------------------------------------------------
% creates the growingpremask popup in panel_roi

handles.popup_growingpremasktype = uicontrol(handles.panel_roimethod,...
    'Style','popup','Units','normalized','background','w',...
    'String',[{'None'};{'Sphere'};{'Mask'}],...
    'FontUnits','normalized','FontSize',fss*.5,...
    'Position',[.52,.29,.47,0.13],...
    'Callback',@popup_growingpremasktype_callback);

%--------------------------------------------------------------------------
% creates the text for premask radius
handles.text_growingpremasradius = uicontrol(handles.panel_roimethod,...
    'Style','text','Units','normalized','String','Radius:',...
    'FontUnits','normalized','FontSize',fss*.7,'BackgroundColor','w',...
    'HorizontalAlignment','left','Position',[.52,.15,.18,.1],...
    'Visible','off');

%--------------------------------------------------------------------------
% creates the edit text for premask radius
handles.edit_growingpremasradius = uicontrol(handles.panel_roimethod,...
    'Style','edit','Units','normalized','String','5',...
    'FontUnits','normalized','FontSize',fss*.7,'BackgroundColor','w',...
    'HorizontalAlignment','left','Position',[.7,.15,.29,.1],...
    'Visible','off');

%--------------------------------------------------------------------------
% creates the text for mask image dropdown menu
handles.text_maskimg = uicontrol(handles.panel_roimethod,...
    'Style','text','Units','normalized',...
    'String','Select the image for premasking:',...
    'FontUnits','normalized','FontSize',fss*.7,'BackgroundColor','w',...
    'HorizontalAlignment','left','Position',[.01,.15,.97,.1],...
    'Visible','off');

%--------------------------------------------------------------------------
% creates the mask image dropdown menu
handles.popup_maskimg = uicontrol(handles.panel_roimethod,...
    'Style','popup','Units','normalized','Position',[.01,.02,.98,.13],...    
    'FontUnits','normalized','FontSize',fss*.5,'background','w',...
    'Visible','off');

set(handles.popup_maskimg,'String',imgnamelist)

guidata(hObject,handles)