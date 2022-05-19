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
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

handles = guidata(hObject);
specialvars = {'hObject';'srcvol';'curpos';'minthrs';'maxthrs'};

v = get(handles.popup_roitype,'Value');
s = get(handles.popup_roitype,'String');
roimth = s{v};
methodpath = fullfile(handles.fmroirootdir,...
    'roimethods','methods',[roimth,'.m']);

[args, ~] = get_arg_names(methodpath);
args = args{1};
args(ismember(args,specialvars)) = [];

%--------------------------------------------------------------------------
% creates the ROIs Panel
panelroi_pos = [0.01, 0.01, 0.98, 0.87];

handles.panel_roimethod = uipanel(handles.tab_genroi, 'BackgroundColor', 'w', ...
    'Units', 'normalized', 'Position', panelroi_pos, 'Visible', 'on');

%--------------------------------------------------------------------------
% creates the text for source image
w = .15; % text width (.21)
h = .08; % text height
lpos = .01; % text left position (.01)
bpos = .9; % text botton position

for i = 1:length(args)
        textlabelpos = [lpos, (1-i)*(h+.01)+bpos, w, h];
        editpos = [lpos+w, (1-i)*(h+.01)+bpos,.98-w, h];
    
    handles.text_autoguilabel(i) = uicontrol(handles.panel_roimethod,...
        'Style','text','Units','normalized','String',args{i},...
        'BackgroundColor', 'w', 'FontSize', 10,...
        'HorizontalAlignment', 'left','Position', textlabelpos);
    
    
    handles.edit_autogui(i) = uicontrol(handles.panel_roimethod,...
        'Style','edit','Units','normalized','String','',...
        'BackgroundColor','w','FontSize',10,...
        'HorizontalAlignment','left','Position',editpos,...
        'Tag',['edit',num2str(i)]);
end

guidata(hObject, handles);