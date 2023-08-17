function axes_screenshot(hObject,~)
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
% Last update: Andre Peres, 03/08/2023, peres.asc@gmail.com


delete_panel_tools(hObject)
create_panel_tools(hObject)

handles = guidata(hObject);

fss = handles.fss; % font size scale

%--------------------------------------------------------------------------
% Set the string in the title bar
set(handles.text_toolstitlebar,'string','Save axes screenshots')

%--------------------------------------------------------------------------
% creates the text for out path
handles.text_outpath = uicontrol(handles.panel_tools,...
    'Style','text','Units','normalized','String','Out path:',...
    'FontUnits','normalized','FontSize',fss*.7,'BackgroundColor','w',...
    'HorizontalAlignment','left','Position',[.01,.8,.4,.08]);
        
%--------------------------------------------------------------------------
% creates the edit text for out path
handles.edit_outscrshtpath = uicontrol(handles.panel_tools,...
    'Style','edit','Units','normalized','BackgroundColor','w',...
    'String',fullfile(pwd,'fmroiscreenshot.png'),...
    'FontUnits','normalized','FontSize',fss*.7,...
    'HorizontalAlignment','left','Position',[.01,.73,.92,.07]);

%--------------------------------------------------------------------------
% creates the uiputfile pushbutton
handles.pbutton_pathscrsht = uicontrol(handles.panel_tools,...
    'Style','PushButton','Units','normalized',...
    'FontUnits','normalized','FontSize',fss*.7,'String','...',...
    'Position',[.935,.73,.055,.07]); %,'Callback',@delete_panel_tools);

%--------------------------------------------------------------------------
% creates the text for popup_scrshtmode
handles.text_scrshtmode = uicontrol(handles.panel_tools,...
    'Style','text','Units','normalized','String','Mode:',...
    'FontUnits','normalized','FontSize',fss*.7,'BackgroundColor','w',...
    'HorizontalAlignment','left','Position',[.01,.6,.2,.08]);

%--------------------------------------------------------------------------
% creates the screeshot mode dropdown menu
handles.popup_scrshtmode = uicontrol(handles.panel_tools,...
    'Style','popup','Units','normalized','background','w',...
    'String',[{'Axes'};{'Multi-slice'};{'Mosaic'}],...
    'FontUnits','normalized','FontSize',fss*.5,'Position',[.21,.58,.3,.1]);

%--------------------------------------------------------------------------
% creates the uiputfile pushbutton
handles.pbutton_savescrsht = uicontrol(handles.panel_tools,...
    'Style','PushButton','Units','normalized',...
    'FontUnits','normalized','FontSize',fss*.7,'String','Save',...
    'Position',[.52,.6,.15,.08],'Callback',@pbutton_savescrsht_callback);


guidata(hObject,handles)