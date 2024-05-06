function applymask(hObject,~)
% axes_screenshot is an internal function of fMROI.
%
% Syntax:
%   axes_screenshot(hObject,~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2023, peres.asc@gmail.com
% Last update: Andre Peres, 22/08/2023, peres.asc@gmail.com


delete_panel_tools(hObject)
create_panel_tools(hObject)

handles = guidata(hObject);

fss = handles.fss; % font size scale

%--------------------------------------------------------------------------
% Set the string in the title bar
set(handles.text_toolstitlebar,'string','Apply Mask')

%==========================================================================
% creates the text for source path
handles.tools.applymask.text_srcpath = uicontrol(handles.panel_tools,...
    'Style','text','Units','normalized','String','Source path:',...
    'FontUnits','normalized','FontSize',fss*.7,'BackgroundColor','w',...
    'HorizontalAlignment','left','Position',[.01,.8,.4,.08]);

% Java fix due uicontrol missing vertical alignment property
jh = findjobj(handles.tools.applymask.text_srcpath);
jh.setVerticalAlignment(javax.swing.JLabel.CENTER);

%--------------------------------------------------------------------------
% creates the edit text for source path
handles.tools.applymask.edit_scrpath = uicontrol(handles.panel_tools,...
    'Style','edit','Units','normalized','BackgroundColor','w',...
    'String','','FontUnits','normalized','FontSize',fss*.7,...
    'HorizontalAlignment','left','Position',[.01,.73,.92,.07]);

%--------------------------------------------------------------------------
% creates the source uigetfile pushbutton
handles.tools.applymask.pbutton_srcpath = uicontrol(handles.panel_tools,...
    'Style','PushButton','Units','normalized','String','...',...
    'FontUnits','normalized','FontSize',fss*.7,...
    'Position',[.935,.73,.055,.07],...
    'Callback',@pbutton_applymaskselectfiles_callback);


%==========================================================================
% creates the text for mask path
handles.tools.applymask.text_maskpath = uicontrol(handles.panel_tools,...
    'Style','text','Units','normalized','String','Mask path:',...
    'FontUnits','normalized','FontSize',fss*.7,'BackgroundColor','w',...
    'HorizontalAlignment','left','Position',[.01,.65,.4,.08]);

% Java fix due uicontrol missing vertical alignment property
jh = findjobj(handles.tools.applymask.text_maskpath);
jh.setVerticalAlignment(javax.swing.JLabel.CENTER);
        
%--------------------------------------------------------------------------
% creates the edit text for mask path
handles.tools.applymask.edit_maskpath = uicontrol(handles.panel_tools,...
    'Style','edit','Units','normalized','BackgroundColor','w',...
    'String','','FontUnits','normalized','FontSize',fss*.7,...
    'HorizontalAlignment','left','Position',[.01,.58,.92,.07]);

%--------------------------------------------------------------------------
% creates the mask uigetfile pushbutton
handles.tools.applymask.pbutton_maskpath = uicontrol(handles.panel_tools,...
    'Style','PushButton','Units','normalized','String','...',...
    'FontUnits','normalized','FontSize',fss*.7,...
    'Position',[.935,.58,.055,.07],...
    'Callback',@pbutton_applymaskselectfiles_callback);


%==========================================================================
% creates the text for output path
handles.tools.applymask.text_outdir = uicontrol(handles.panel_tools,...
    'Style','text','Units','normalized','String','Output folder:',...
    'FontUnits','normalized','FontSize',fss*.7,'BackgroundColor','w',...
    'HorizontalAlignment','left','Position',[.01,.5,.4,.08]);

% Java fix due uicontrol missing vertical alignment property
jh = findjobj(handles.tools.applymask.text_outdir);
jh.setVerticalAlignment(javax.swing.JLabel.CENTER);
        
%--------------------------------------------------------------------------
% creates the edit text for output path
handles.tools.applymask.edit_outdir = uicontrol(handles.panel_tools,...
    'Style','edit','Units','normalized','BackgroundColor','w',...
    'String',pwd,'FontUnits','normalized','FontSize',fss*.7,...
    'HorizontalAlignment','left','Position',[.01,.43,.92,.07]);

%--------------------------------------------------------------------------
% creates the output uiputfile pushbutton
handles.tools.applymask.pbutton_outdir = uicontrol(handles.panel_tools,...
    'Style','PushButton','Units','normalized','String','...',...
    'FontUnits','normalized','FontSize',fss*.7,...
    'Position',[.935,.43,.055,.07],...
    'Callback',@pbutton_applymaskselectfiles_callback);

%==========================================================================
% creates the run pushbutton
handles.pbutton_savescrsht = uicontrol(handles.panel_tools,...
    'Style','PushButton','Units','normalized','String','Run',...
    'FontUnits','normalized','FontSize',fss*.7,...
    'Position',[.68,.3,.15,.08],'Callback',@pbutton_applymaskrun_callback);


guidata(hObject,handles)