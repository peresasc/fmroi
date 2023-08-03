function create_panel_roi(hObject)
% create_panel_roi is a internal function of fMROI dedicated to create the
% panel and uicontrols for creating ROIs.
%
% Syntax:
%   create_panel_roi(hObject)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 03/08/2023, peres.asc@gmail.com

handles = guidata(hObject);


panelroi_pos = [0.01, 0.01, 0.98, 0.35];    

handles.tabgp = uitabgroup(handles.panel_control,'Position',panelroi_pos);

%--------------------------------------------------------------------------
% creates the ROI Table tab
%--------------------------------------------------------------------------

handles.tab_roitable = uitab(handles.tabgp,'BackgroundColor','w',...
    'Units','normalized','Title','ROI Table');

tableroi_pos = [0.01, 0.12, 0.98, 0.87];

handles.table_roilut = uitable(handles.tab_roitable,...
    'Data',cell(1,6),'Units','normalized','Position',tableroi_pos,...
    'FontUnits','normalized','FontSize',.06);

set(handles.table_roilut,'units','pixel')
tablewidth = handles.table_roilut.Position(3)-40;

colwidth = cell(1,3);
colwidth{1} = .1 * tablewidth;
colwidth{2} = .5 * tablewidth;
colwidth{3} = .1 * tablewidth;
colwidth{4} = .1 * tablewidth;
colwidth{5} = .1 * tablewidth;
colwidth{6} = .1 * tablewidth;
set(handles.table_roilut,'units','normalized','ColumnWidth',colwidth,...
    'ColumnName',{'Idx';'ROI name';'R';'G';'B';'A'},...
    'ColumnEditable', [true true true true true true],...
    'CellEditCallback',@table_roilut_editcallback)


handles.pbutton_roidel = uicontrol(handles.tab_roitable,...
    'Style','PushButton','Units','normalized','String','Del',...
    'FontUnits','normalized','FontSize',.5,'Position',[.01,.01,.12,.1],...
    'Callback',@pbutton_roidel_callback);

handles.pbutton_roiclear = uicontrol(handles.tab_roitable,...
    'Style','PushButton','Units','normalized','String','Clear',...
    'FontUnits','normalized','FontSize',.5,'Position',[.14,.01,.12,.1],...
    'Callback',@pbutton_roiclear_callback);

handles.pbutton_roisave = uicontrol(handles.tab_roitable,...
    'Style','PushButton','Units','normalized','String','Save',...
    'FontUnits','normalized','FontSize',.5,'Position',[.27,.01,.12,.1],...
    'Callback',@pbutton_roisave_callback);

%--------------------------------------------------------------------------
% creates the Checkbox Group in panel_roi  

handles.buttongroup_roisave = uibuttongroup(handles.tab_roitable,...
    'BackgroundColor', 'w', 'Units', 'normalized',...
    'Position', [0.40, 0.01, 0.59, 0.1]);
%--------------------------------------------------------------------------
% creates the roisavemulti checkbox
handles.checkbox_roisavebinmasks = uicontrol(...
    handles.buttongroup_roisave,'Style','checkbox','Value',1,...
    'Units','normalized','Position',[.01,.01,.45,.98],...
    'FontUnits','normalized','FontSize',.6,...
    'String','Bin masks','BackgroundColor','w');

%--------------------------------------------------------------------------
% creates the roisavesingle checkbox
handles.checkbox_roisaveatlas = uicontrol(...
    handles.buttongroup_roisave, 'Style', 'checkbox','Value',1,...
    'Units','normalized','Position',[.46,.01,.53,.98],...
    'FontUnits','normalized','FontSize',.6,...
    'String','Atlas + LUT','BackgroundColor','w');


%--------------------------------------------------------------------------
% creates the ROI Methods tab
%--------------------------------------------------------------------------

handles.tab_genroi = uitab(handles.tabgp,'BackgroundColor','w', ...
    'Units','normalized','Title','ROI Gen');

%--------------------------------------------------------------------------
% creates the ROI type dropdown menu

bb = .89;
bw = .18;
bh = .09;

handles.text_roitypelabel = uicontrol(handles.tab_genroi,...
    'Style','text','Units','normalized','String','Method:',...
    'FontUnits','normalized','FontSize',.6,'BackgroundColor','w',...
    'HorizontalAlignment','left','Position',[0,.88,.15,.08]);


handles.popup_roitype = uicontrol(handles.tab_genroi,...
    'Style','popup','Units','normalized',...
    'FontUnits','normalized','FontSize',.4,'background','w',...
    'Position', [.15,.84,.46,.14],'Callback',@popup_roitype_callback);

guidata(hObject,handles);
updatepopuproitype(hObject)
handles = guidata(hObject);

%--------------------------------------------------------------------------
% creates the find max roi pushbutton
handles.pbutton_findmax = uicontrol(handles.tab_genroi,...
    'Style','PushButton','Units','normalized',...
    'FontUnits','normalized','FontSize',.5,'String','Find max',...
    'Position',[.62,bb,bw,bh],'Callback',@pbutton_findmax_callback);

%--------------------------------------------------------------------------
% creates the roi pushbutton
handles.pbutton_roi = uicontrol(handles.tab_genroi,...
    'Style','PushButton','Units','normalized',...
    'FontUnits','normalized','FontSize',.5,'String','Gen Roi',...
    'Position',[.81,bb,bw,bh],'Callback',@pbutton_roi_callback);

%--------------------------------------------------------------------------
% creates the logic chain tab
%--------------------------------------------------------------------------

tableroi_pos = [0.01, 0.01, 0.98, 0.75];
d = cell(10,3);
colwidth = cell(1,2);

handles.tab_logicchain = uitab(handles.tabgp,'BackgroundColor','w',...
    'Units','normalized','Title','Logic Op');

handles.table_roilc = uitable(handles.tab_logicchain,'Data',d,...
    'Units','normalized','FontUnits','normalized','FontSize',.07,...
    'Position',tableroi_pos);

set(handles.table_roilc,'units','pixel')
tablewidth = handles.table_roilc.Position(3)-50;
colwidth{1} = .85 * tablewidth;
colwidth{2} = .15 * tablewidth;
colwidth{3} = .15 * tablewidth;
set(handles.table_roilc,'units','normalized','ColumnWidth',colwidth,...
    'ColumnName',{'Image';'LOp';'Type'})

%--------------------------------------------------------------------------
% creates the mask to logic chain dropdown menu
handles.popup_lcmask = uicontrol(handles.tab_logicchain,...
    'Style','popup','Units','normalized','background','w',...
    'FontUnits','normalized','FontSize',.4,'Position',[.01,.86,.98,.12]);

guidata(hObject,handles);
imgnamelist = getimgnamelist(hObject);
set(handles.popup_lcmask,'String',imgnamelist)

%--------------------------------------------------------------------------
% creates the operators to logic chain dropdown menu

handles.text_lcoperatorlabel = uicontrol(handles.tab_logicchain,...
    'Style','text','Units','normalized','String','Logic op:',...
    'FontUnits','normalized','FontSize',.7,'BackgroundColor','w',...
    'HorizontalAlignment','left','Position',[.01,.78,.19,.08]);

handles.popup_lcoperator = uicontrol(handles.tab_logicchain,...
    'Style','popup','Units','normalized','background','w',...
    'FontUnits','normalized','FontSize',.4,'Position',[.20,.75,.14,.12]);

lo{1} = 'AND';
lo{2} = 'OR';
lo{3} = 'NOT';
lo{4} = 'end';

set(handles.popup_lcoperator,'String',lo)

bl = .36;
bb = .78;
bw = .15;
bh = .09;
%--------------------------------------------------------------------------
% creates the tooglebutton to catch Images or ROIs for logic chain
handles.tbutton_lcsrcsel = uicontrol(handles.tab_logicchain,...
    'Style','ToggleButton','Units','normalized','String','Image',...
    'FontUnits','normalized','FontSize',.5,...
    'Position',[bl, bb, bw, bh],'Callback',@tbutton_lcsrcsel_callback);

%--------------------------------------------------------------------------
% creates the pushbutton to insert values in the table_roilc
handles.pbutton_lcinsert = uicontrol(handles.tab_logicchain,...
    'Style','PushButton','Units','normalized','String','Insert',...
    'FontUnits','normalized','FontSize',.5,...
    'Position',[bl+bw+.01,bb,bw,bh],...
    'Callback',@pbutton_lcinsert_callback);

%--------------------------------------------------------------------------
% creates the pushbutton to run the logic_chain with the table_roilc values
handles.pbutton_lcclear = uicontrol(handles.tab_logicchain,...
    'Style','PushButton','Units','normalized','String','Clear',...
    'FontUnits','normalized','FontSize',.5,...
    'Position',[bl+2*(bw+.01),bb,bw,bh],...
    'Callback',@pbutton_lcclear_callback);

%--------------------------------------------------------------------------
% creates the pushbutton to run the logic_chain with the table_roilc values
handles.pbutton_lcrun = uicontrol(handles.tab_logicchain,'String','Run',...
    'Style','PushButton','Units','normalized',...
    'FontUnits','normalized','FontSize',.5,...
    'Position',[bl+3*(bw+.01),bb,bw,bh],...
    'Callback',@pbutton_lcrun_callback);

guidata(hObject, handles);

