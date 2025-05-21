function create_panel_settings(hObject,~)
% create_panel_tools is a internal function of fMROI dedicated to create
% the panel for extra_tools uicontrols.
%
% Syntax:
%   create_panel_tools(hObject)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2023, peres.asc@gmail.com
% Last update: Andre Peres, 17/08/2023, peres.asc@gmail.com

delete_panel_settings(hObject)
handles = guidata(hObject);

fss = handles.fss; % font size scale

panel_pos = [0.26,0.01,.73,.98];    

handles.panel_settings = uipanel(gcf,'BackgroundColor','w',...
    'Units','normalized','Position',panel_pos);

%--------------------------------------------------------------------------
% creates the title bar

handles.text_settingstitlebar = uicontrol(handles.panel_settings,...
    'Style','text','Units','normalized','FontWeight','normal',...
    'String','Advanced Settings','BackgroundColor',[.9,.9,.9],...
    'FontUnits','normalized','FontSize',fss*.7,...
    'HorizontalAlignment','center','Position',[0,.96,1,.04]);

%--------------------------------------------------------------------------
% creates the close icon pushbutton
handles.pbutton_panelsettingscloseicon = uicontrol(handles.panel_settings,...
    'Style','PushButton','Units','normalized',...
    'FontUnits','normalized','FontSize',fss*.8,'String','x',...
    'BackgroundColor','r','ForeGroundColor','w','FontWeight','bold',...
    'Position',[.965,.96,.035,.04],'HorizontalAlignment','center',...
    'Callback',@delete_panel_settings);

%--------------------------------------------------------------------------
% creates the cancel pushbutton
handles.pbutton_panelsettingscancel = uicontrol(handles.panel_settings,...
    'Style','PushButton','Units','normalized','String','Cancel',...
    'FontUnits','normalized','FontSize',fss*.5,...
    'Position',[.32,.01,.08,.05],'HorizontalAlignment','center',...
    'Callback',@delete_panel_settings);


%--------------------------------------------------------------------------
% creates the done pushbutton
handles.pbutton_panelsettingsdone = uicontrol(handles.panel_settings,...
    'Style','PushButton','Units','normalized','String','Done',...
    'FontUnits','normalized','FontSize',fss*.5,...
    'Position',[.41,.01,.08,.05],'HorizontalAlignment','center',...
    'Callback',@delete_panel_settings);

guidata(hObject,handles);

