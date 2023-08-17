function create_panel_tools(hObject,~)
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

handles = guidata(hObject);

fss = handles.fss; % font size scale

panel_pos = [0.01, 0.01, 0.98, 0.35];    

handles.panel_tools = uipanel(handles.panel_control,...
    'BackgroundColor','w','Units','normalized','Position',panel_pos);

%--------------------------------------------------------------------------
% creates the title bar

handles.text_toolstitlebar = uicontrol(handles.panel_tools,...
    'Style','text','Units','normalized','FontWeight','normal',...
    'String','','BackgroundColor',[.9,.9,.9],...
    'FontUnits','normalized','FontSize',fss*.8,...
    'HorizontalAlignment','center','Position',[0,.92,1,.08]);

%--------------------------------------------------------------------------
% creates the close icon pushbutton
handles.pbutton_paneltoolscloseicon = uicontrol(handles.panel_tools,...
    'Style','PushButton','Units','normalized',...
    'FontUnits','normalized','FontSize',fss*.8,'String','x',...
    'BackgroundColor','r','ForeGroundColor','w','FontWeight','bold',...
    'Position',[.94,.94,.05,.05],'HorizontalAlignment','center',...
    'Callback',@delete_panel_tools);

%--------------------------------------------------------------------------
% creates the close pushbutton
handles.pbutton_paneltoolsclose = uicontrol(handles.panel_tools,...
    'Style','PushButton','Units','normalized',...
    'FontUnits','normalized','FontSize',fss*.7,'String','Close',...
    'Position',[.84,.01,.15,.07],'Callback',@delete_panel_tools);


guidata(hObject,handles);

