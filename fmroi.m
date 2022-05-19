function fmroi()
% fMROI is a software dedicated to create ROIs in fMRI images...
%
% Syntax: fmroi
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

clear global
set(0,'units','pixels');
scnsize = get(0,'screensize');
figw = ceil(scnsize(3)*0.9);
figh = floor(scnsize(4)*0.8);
[fmroirootdir,~,~] = fileparts(mfilename('fullpath'));

addpath(fullfile(fmroirootdir,'callback'),...
    fullfile(fmroirootdir,'gui'),...
    fullfile(fmroirootdir,'methods'));

addpath(genpath(fullfile(fmroirootdir,'toolbox')));
addpath(genpath(fullfile(fmroirootdir,'roimethods')));

tmpdir = fullfile(fmroirootdir,'tmp');
if exist(tmpdir,'dir')
    rmdir(tmpdir, 's');
end
mkdir(tmpdir);

templatedir = fullfile(fmroirootdir,'templates');
if ~exist(templatedir,'dir')
   mkdir(templatedir);
end
handles.tpldir = templatedir;
% templatestruc = dir(templatedir);
% tpldirstruc = templatestruc([templatestruc(:).isdir]);
% tpldirstruc = tpldirstruc(~startsWith({tpldirstruc(:).name},'.'));
% templatedirname = {tpldirstruc(:).name};


% Figure creation
% hObject is the handle to the figure
hObject = figure('Name', 'Parameters Detection', 'Color', [255 255 255]/255, ...
    'MenuBar', 'none', 'ToolBar', 'none',... , 'CloseRequestFcn', @close_signalhunter,...
    'DockControls', 'off', 'NumberTitle','off','Render','opengl', 'Visible', 'off');

set(hObject, 'Units', 'Pixels', 'Position', [0 0 figw figh],'windowbuttonmotionfcn',@mousemove);
% center the figure window on the screen
movegui(hObject, 'center');

%--------------------------------------------------------------------------
% creates the menu bar 1 with 1 submenu
hmenufile = uimenu('Label', 'File', 'Parent', hObject);

%--------------------------------------------------------------------------
% creates the File submenus
hmenufile_open = uimenu(hmenufile, 'Label', 'Open',...
    'Callback', @menufile_open_callback);

handles.hmenufile_templates(1) = uimenu(hmenufile, 'Label', 'Load Template');

%--------------------------------------------------------------------------
% Create the templates submenus automatically
guidata(hObject,handles);
updatemenutemplate(hObject);
handles = guidata(hObject);
%--------------------------------------------------------------------------

hmenufile_roi = uimenu(hmenufile, 'Label', 'Load ROIs',...
    'Callback', @menufile_roiopen_callback);

hmenufile_exit = uimenu(hmenufile, 'Label', 'Exit',...
    'Callback', @menufile_exit_callback);

%--------------------------------------------------------------------------
% creates the menu bar 2 with 1 submenu
hmenuconfig = uimenu('Label', 'Config', 'Parent', hObject);

hmenuconfig_dplres = uimenu(hmenuconfig, 'Label', 'Display resolution');%,...
%     'Callback', @menufile_open_callback);

hmenuconfig_imptpl = uimenu(hmenuconfig, 'Label', 'Import template',...
     'Callback', @menuconfig_imptpl_callback);
% hmenuconfig_imptpl_file = uimenu(hmenuconfig_imptpl, 'Label', 'Files',...
%     'Callback', @menuconfig_imptpl_callback);
% 
% hmenuconfig_imptpl_file = uimenu(hmenuconfig_imptpl, 'Label', 'Folder',...
%     'Callback', @menuconfig_imptpl_callback);

hmenuconfig_cleartpl = uimenu(hmenuconfig,'Label','Clear template folder',...
    'Callback', @menuconfig_cleartpl_callback);

hmenuconfig_restoretpl = uimenu(hmenuconfig,'Label','Restore default templates',...
    'Callback', @menuconfig_restoretpl_callback);

hmenuconfig_improifun = uimenu(hmenuconfig, 'Label', 'Import ROI function',...
    'Callback', @menuconfig_improifun_callback);

hmenuconfig_restoreroifun = uimenu(hmenuconfig, 'Label', 'Restore default ROI functions',...
    'Callback', @menuconfig_restoreroifun_callback);

%--------------------------------------------------------------------------
% creates the menu bar 3 with 1 submenu
hmenutools = uimenu('Label', 'Tools', 'Parent', hObject);

%--------------------------------------------------------------------------
% creates the menu bar 4 with 1 submenu
hmenuhelp = uimenu('Label', 'Help', 'Parent', hObject);

%--------------------------------------------------------------------------
% creates the Axes Panel

panelgraph_pos = [0.26, 0.01, 0.73, 0.98];

handles.panel_graph = uipanel(hObject, 'BackgroundColor', 'k', ...
    'Units', 'normalized', 'Visible', 'on', 'Position', panelgraph_pos);

%--------------------------------------------------------------------------
% creates the Control Panel
panelbuttons_pos = [0.01, 0.01, 0.24, 0.98];

handles.panel_control = uipanel(hObject, 'BackgroundColor', 'w', ...
    'Units', 'normalized', 'Position', panelbuttons_pos);

%--------------------------------------------------------------------------
% creates the Control Panel objects
guidata(hObject,handles);
create_panel_mainctrl(hObject);
handles = guidata(hObject);

%--------------------------------------------------------------------------
% Set the objects to handles

handles.fig = hObject;
handles.fmroirootdir = fmroirootdir;
handles.tmpdir = tmpdir;
handles.hmenufile = hmenufile;
handles.hmenuhelp = hmenuhelp;
handles.hsubopen = hmenufile_open;
% handles.hsub2open = hmenufile_templates2;
% handles.hsub3open = hmenufile_templates3;
handles.hsubexit = hmenufile_exit;
handles.config_dir = [];


set(hObject,'Visible','on');

% Update handles structure
guidata(hObject,handles);

function menufile_exit_callback(hObject, ~)
handles = guidata(hObject);
selection = questdlg('Do you want to exit fMROI?',...
      'Exit fMROI',...
      'Yes','No','Yes'); 
   switch selection 
      case 'Yes'
         delete(handles.fig)
      case 'No'
      return
   end
% close(handles.fig)
