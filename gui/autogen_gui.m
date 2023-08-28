function autogen_gui(hObject)
% autogen_gui is a internal function of fMROI. It automatically creates
% panels and uicontrols for ROI functions that don't have caller and gui
% functions.
%
% Syntax:
%   autogen_gui(hObject)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 04/08/2023, peres.asc@gmail.com

handles = guidata(hObject);
specialvars = {'hObject';'srcvol';'curpos';'minthrs';'maxthrs'};
fss = handles.fss; % font size scale

v = get(handles.popup_roitype,'Value');
s = get(handles.popup_roitype,'String');
roimth = s{v};
% methodpath = fullfile(handles.fmroirootdir,...
%     'roimethods','methods',[roimth,'.m']);

fs = dir([handles.roimethdir,filesep,'**',filesep,roimth,'.m']);

if isempty(fs)
    methodpath = '';
else
    methodpath = fullfile(fs.folder,fs.name);
end

[args, ~] = get_arg_names(methodpath);
args = args{1};
args(ismember(args,specialvars)) = [];

%--------------------------------------------------------------------------
% creates the ROIs Panel
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
% creates the text for source image
w = .3; % text width (.21)
h = .1; % text height
lpos = .01; % text left position (.01)
bpos = .68; % text botton position

for i = 1:length(args)
        textlabelpos = [lpos, (1-i)*(h+.02)+bpos, w, h];
        editpos = [lpos+w, (1-i)*(h+.02)+bpos,.98-w, h];
    
    handles.text_autoguilabel(i) = uicontrol(handles.panel_roimethod,...
        'Style','text','Units','normalized','String',args{i},...
        'FontUnits','normalized','FontSize',fss*.7,'BackgroundColor','w',...
        'HorizontalAlignment','left','Position',textlabelpos);
    
    
    handles.edit_autogui(i) = uicontrol(handles.panel_roimethod,...
        'Style','edit','Units','normalized','String','',...
        'FontUnits','normalized','FontSize',fss*.7,'BackgroundColor','w',...
        'HorizontalAlignment','left','Position',editpos,...
        'Tag',['edit',num2str(i)]);
end

guidata(hObject, handles);