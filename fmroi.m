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
    fullfile(fmroirootdir,'methods'),...
    fullfile(fmroirootdir,'etc','figs'));

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

%--------------------------------------------------------------------------
% Create main Figure
hObject = figure('Name','fMROI 1.0.0','Color','w', ...
    'MenuBar','none','ToolBar','none','NumberTitle','off',...
    'DockControls','off','Render','opengl','Units','Pixels',...
    'Position', [0 0 figw figh],'windowbuttonmotionfcn',@mousemove,...
    'WindowButtonDownFcn',@mousehold,'WindowButtonUpFcn',@mouserelease,...
    'KeyPressFcn', @keypress_callback);

set(hObject,'Visible','off');

% center the figure window on the screen
movegui(hObject, 'center');
handles.mousehold = 0;
handles.toolbar = 0;
%--------------------------------------------------------------------------
% creates the menu File
hmenufile = uimenu('Label', 'File', 'Parent', hObject);

% Open submenus
hmenufile_open = uimenu(hmenufile, 'Label', 'Open',...
    'Callback', @menufile_open_callback);

% Load Template submenu
handles.hmenufile_templates(1) = uimenu(hmenufile,...
    'Label','Load Template','Tag',templatedir);

% Create the Load Templates submenus automatically
guidata(hObject,handles);
updatemenutemplate(hObject);
handles = guidata(hObject);

% Load ROIs submenu
hmenufile_roi = uimenu(hmenufile, 'Label', 'Load ROIs',...
    'Callback', @menufile_roiopen_callback);

% Exit submenu
hmenufile_exit = uimenu(hmenufile, 'Label', 'Exit',...
    'Callback', @menufile_exit_callback);

%--------------------------------------------------------------------------
% Create Config Menu
hmenuconfig = uimenu('Label', 'Config', 'Parent', hObject);

hmenuconfig_imptpl = uimenu(hmenuconfig, 'Label', 'Import template',...
     'Callback', @menuconfig_imptpl_callback);

hmenuconfig_cleartpl = uimenu(hmenuconfig,'Label','Clear template folder',...
    'Callback', @menuconfig_cleartpl_callback);

hmenuconfig_restoretpl = uimenu(hmenuconfig,'Label','Restore default templates',...
    'Callback', @menuconfig_restoretpl_callback);

hmenuconfig_improifun = uimenu(hmenuconfig, 'Label', 'Import ROI function',...
    'Callback', @menuconfig_improifun_callback);

hmenuconfig_restoreroifun = uimenu(hmenuconfig, 'Label', 'Restore default ROI functions',...
    'Callback', @menuconfig_restoreroifun_callback);

%--------------------------------------------------------------------------
% Create View menu

hmenuview = uimenu('Label', 'View', 'Parent', hObject);

hmenuconfig_dplres = uimenu(hmenuview, 'Label', 'Display resolution',...
    'Callback', @menuconfig_dplres_callback);

hmenuview_showquickguide = uimenu(hmenuview,'Label','Show quick guide',...
    'Callback', @menuhelp_showquickguide_callback);

handles.menuview_showctrlpanel = uimenu(hmenuview,...
    'Label','Show Control Panel','Enable','off',...
    'Callback', @menuhelp_showctrlpanel_callback);


%--------------------------------------------------------------------------
% Create Tools menu
hmenutools = uimenu('Label', 'Tools', 'Parent', hObject);

%--------------------------------------------------------------------------
% Create Help menu
hmenuhelp = uimenu('Label', 'Help', 'Parent', hObject);

hmenuhelp_about = uimenu(hmenuhelp,'Label','About');
%     'Callback', @menuhelp_showctrlpanel_callback);

hmenuhelp_showquickguide = uimenu(hmenuhelp,'Label','Show quick guide',...
    'Callback', @menuhelp_showquickguide_callback);

hmenuhelp_documentation = uimenu(hmenuhelp,'Label','Documentation',...
    'Callback', @menuhelp_forward_to_documentation);

%--------------------------------------------------------------------------
% creates the Axes Panel

panelgraph_pos = [0.26, 0.01, 0.365, 0.49;...
                  0.26, 0.5, 0.365, 0.49;...
                  0.625, 0.5, 0.365, 0.49;...
                  0.625, 0.01, 0.365, 0.49];

for i = 1:4
    handles.panel_graph(i) = uipanel(hObject, 'BackgroundColor', 'k', ...
        'Units', 'normalized', 'Visible', 'on',...
        'Position', panelgraph_pos(i,:));
end

%--------------------------------------------------------------------------
% creates the Control Panel and Welcome panel
panelcontrol_pos = [0.01, 0.01, 0.24, 0.98];

handles.panel_logo = uipanel(hObject, 'BackgroundColor', 'w', ...
    'Units', 'normalized', 'Position', panelcontrol_pos,'Tag','panel_logo');

handles.panel_control = uipanel(hObject, 'BackgroundColor', 'w', ...
    'Units', 'normalized', 'Position', panelcontrol_pos);

%--------------------------------------------------------------------------
% creates the Welcome text
wt = {'Welcome to fMROI Apha 1.0.0';...
    '';...
    ['fMROI is a free software designed to create regions of',...
    'interest (ROI) in functional magnetic resonance imaging',...
    '(fMRI). However, it is not limited to fMRI, and can be used',...
    'with structural images, diffusion maps (DTI), or even with',...
    'atlases such as FreeSurfer aparc-aseg and Julich atlas.'];...
    '';...
    'To load an image, the users have three alternatives:';...
    ['1. by clicking on "File>Open menu", to open a nifti file',...
    '(functional, structural, DTI, etc.);'];...
    ['2. by clicking on the menu "File>Load ROI" to open a',...
    'binary nifti file and automatically use it as ROI;'];...
    ['3. clicking on "File>Load Template" to open one of the',...
    'templates installed in fMROI.'];...
    '';...
    ['After loading the image, users can create and manipulate',...
    'ROIs in the tabs at the bottom of the control panel. To',...
    'create an ROI, the user must click on the "Gen ROI" tab,',...
    'select the method from the popup menu, adjust the',...
    'parameters and when ready, click on the "Gen ROI" button.'];...
    ['After this procedure the generated ROI will appear in the',...
    '"ROI Table" tab, as well as an image will appear in the list',...
    'of loaded images (roi_under-construction.nii).'];...
    ['To save the ROIs, the user must select the "Bin Mask"',...
    'checkbox to save each ROI as an independent mask, or',...
    '"Atlas+LUT" to save all the ROIs in the same image and ',...
    'click on the "Save" buttom at the botton of "ROI Table" tab.'];...
    '';...
    'For the complete documentation:';...
    'https://github.com/Proaction-Lab/fmroi'};


textquickguidepos = [0.01, 0.35, 0.98, 0.64];

handles.text_quickguide = uicontrol(handles.panel_logo, 'Style', 'text',...
        'Units', 'normalized', 'String', wt,...
        'BackgroundColor','w', 'FontSize', 1/3,'FontUnits','normalized',...
        'HorizontalAlignment', 'left','Position', textquickguidepos);

% ha = annotation(handles.panel_logo,'textbox','Position',textwelcomepos,...
%     'String',wt,'EdgeColor',[.8 .8 .8]);
% set(ha,'FitBoxToText','off')

%--------------------------------------------------------------------------
% creates the Logo axis and text
axeslogo_pos = [0.2545,0.12,0.4711,0.2000];

handles.axislogo = axes('Parent', handles.panel_logo,'Position',axeslogo_pos, 'Box', 'off',...
    'Units', 'normalized','XTick', [],'YTick', []);
            
imshow(fullfile(fmroirootdir,'etc','figs','fmroi_logo.png'))

set(handles.axislogo, 'Tag', 'axislogo')

logocaption = {'Developed by members and colaborators of';...
    'Proaction Lab - FPCE, University of Coimbra';...
    'Rua do Colégio Novo - 3001-802 Coimbra, Portugal';...
    'https://proactionlab.fpce.uc.pt'};

textlogopos = [0.01, 0.01, 0.98, 0.09];
handles.textlogo = uicontrol(handles.panel_logo, 'Style', 'text',...
    'Units', 'normalized', 'String', logocaption,'FontUnits','normalized',...
    'BackgroundColor', [1 1 1], 'FontSize', 1/6,'FontAngle','italic',...
        'HorizontalAlignment', 'center','Position', textlogopos);

% %--------------------------------------------------------------------------
% % creates the Logo axis and text
% axeslogo_pos = [0 0 1 1];
% 
% handles.axislogo = axes('Parent', handles.panel_logo,'Position',axeslogo_pos, 'Box', 'off',...
%     'Units', 'normalized','XTick', [],'YTick', []);
% 
% auximg = imread(fullfile(fmroirootdir,'etc','figs','quickguide.png'));
% auximgsharp = imsharpen(auximg);
% imshow(auximgsharp,'Interpolation','bilinear')
% 
% set(handles.axislogo, 'Tag', 'axislogo')

%--------------------------------------------------------------------------
% creates the Control Panel objects
guidata(hObject,handles);
create_panel_mainctrl(hObject);
handles = guidata(hObject);

set(handles.panel_control,'Visible','off');
%--------------------------------------------------------------------------
% Set the objects to handles

handles.fig = hObject;
handles.fmroirootdir = fmroirootdir;
handles.tmpdir = tmpdir;
handles.hmenufile = hmenufile;
handles.hmenuhelp = hmenuview;
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
