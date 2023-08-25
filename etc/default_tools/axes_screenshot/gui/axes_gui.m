function axes_gui(hObject)
% axes_gui is an internal function of fMROI.
%
% Syntax:
%   axes_gui(hObject)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2023, peres.asc@gmail.com
% Last update: Andre Peres, 23/08/2023, peres.asc@gmail.com

handles = guidata(hObject);
fss = handles.fss; % font size scale

if isfield(handles,'panel_scrshtctrl')
    if isobject(handles.panel_scrshtctrl)
        if isvalid(handles.panel_scrshtctrl)
            delete(handles.panel_scrshtctrl)
        end
    end
end


%--------------------------------------------------------------------------
% creates a new blank panel screenshot controls
handles.panel_scrshtctrl = uipanel(handles.panel_tools,...
    'BackgroundColor','w','Units','normalized',...
    'Position',[.01,.01,.98,.56]);


%--------------------------------------------------------------------------
% creates the Checkbox Group in scrshtctrl  
handles.text_axes2scrsht = uicontrol(handles.panel_scrshtctrl,...
    'Style','text','Units','normalized',...
    'String','Axes','BackgroundColor','w',...
    'FontUnits','normalized','FontSize',fss*.7,...
    'Position',[.01,.82,.2,.15],'HorizontalAlignment','center');

handles.buttongroup_axes2save = uibuttongroup(handles.panel_scrshtctrl,...
    'BackgroundColor', 'w', 'Units', 'normalized',...
    'Position', [0.21,.81,.78,.18]);

an = {'Axi';'Cor';'Sag';'Vol'};
for i = 1:4
handles.checkbox_saveaxis(i) = uicontrol(handles.buttongroup_axes2save,...
    'Style','checkbox','Value',1,'Units','normalized','String',an{i},...
    'FontUnits','normalized','FontSize',fss*.7,'BackgroundColor','w',...
    'Position',[0+(.25*(i-1)),0,.25,1]);
end

%--------------------------------------------------------------------------
% creates the radiobutton Group in scrshtctrl
handles.text_slices2scrsht = uicontrol(handles.panel_scrshtctrl,...
    'Style','text','Units','normalized',...
    'String','Slices','BackgroundColor','w',...
    'FontUnits','normalized','FontSize',fss*.7,...
    'Position',[.01,.6,.2,.15],'HorizontalAlignment','center');

handles.buttongroup_slices2scrsht = uibuttongroup(handles.panel_scrshtctrl,...
    'BackgroundColor', 'w', 'Units', 'normalized',...
    'Position', [0.21,.59,.78,.18]);

sn = {'Current slices';'Select slices'};
for i = 1:2
handles.radio_slices(i) = uicontrol(handles.buttongroup_slices2scrsht,...
    'Style','radiobutton','Value',2-i,'Units','normalized','String',sn{i},...
    'FontUnits','normalized','FontSize',fss*.7,'BackgroundColor','w',...
    'Position',[0+(.5*(i-1)),0,.5,1],'Callback',@radio_slices_callback);
end


%--------------------------------------------------------------------------
%creates the edit text for the mosaic columns
h = .15;
d = .02;
y1 = .02 + (h+d)*2;
for i = 1:3
    handles.text_slices2save(i) = uicontrol(handles.panel_scrshtctrl,...
        'Style','text','Units','normalized',...
        'String',an{i},'BackgroundColor','w',...
        'FontUnits','normalized','FontSize',fss*.7,...
        'Position',[.01,y1-(h+d)*(i-1),.2,h],'HorizontalAlignment','center');

    handles.edit_slices2save(i) = uicontrol(handles.panel_scrshtctrl,...
        'Style','edit','Units','normalized','String','1','Enable','off',...
        'FontUnits','normalized','FontSize',fss*.7,'BackgroundColor','w',...
        'HorizontalAlignment','left','Position',[0.21,y1-(h+d)*(i-1),.78,h]);
end

guidata(hObject,handles)
