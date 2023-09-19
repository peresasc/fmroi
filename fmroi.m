function fmroi()
% fMROI is a powerful and user-friendly software designed to simplify ROI
% creation and enhance neuroimage visualization. Developed with a focus on
% ease of use and compatibility, fMROI offers a range of features that make
% it an ideal tool for researchers in the field of neuroimaging.
% 
% Visit the user guide webpage for usage instructions:
% https://fmroi-docs.readthedocs.io
%
% Syntax: fmroi
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 30/08/2023, peres.asc@gmail.com

clear global


[fmroirootdir,~,~] = fileparts(mfilename('fullpath'));

tmpdir = fullfile(fmroirootdir,'tmp');
if exist(tmpdir,'dir')
    rmdir(tmpdir, 's');
end
mkdir(tmpdir);

templatedir = fullfile(fmroirootdir,'templates');
if ~exist(templatedir,'dir')
   mkdir(templatedir);
end

toolsdir = fullfile(fmroirootdir,'tools');
if ~exist(toolsdir,'dir')
   mkdir(toolsdir);
end

roimethdir = fullfile(fmroirootdir,'roimethods');
if ~exist(roimethdir,'dir')
   mkdir(roimethdir);
end

handles.version = 'fMROI 1.0.0';
handles.webdoc = 'https://fmroi-docs.readthedocs.io';
handles.github = 'https://github.com/proactionlab/fmroi';

handles.fmroirootdir = fmroirootdir;
handles.tpldir = templatedir;
handles.toolsdir = toolsdir;
handles.roimethdir = roimethdir;

addpath(fullfile(fmroirootdir,'callback'),...
    fullfile(fmroirootdir,'gui'),...
    fullfile(fmroirootdir,'methods'),...
    fullfile(fmroirootdir,'etc','figs'));

addpath(genpath(fullfile(fmroirootdir,'toolbox')));
addpath(genpath(handles.toolsdir));
addpath(genpath(handles.roimethdir));


%--------------------------------------------------------------------------
% Create main Figure
hObject = figure('Name',handles.version,'Color','w', ...
    'MenuBar','none','ToolBar','none','NumberTitle','off',...
    'DockControls','off','Render','opengl','units','normalized',...
    'outerposition',[0 0 1 1],'windowbuttonmotionfcn',@mousemove,...
    'WindowButtonDownFcn',@mousehold,'WindowButtonUpFcn',@mouserelease,...
    'KeyPressFcn', @keypress_callback);

set(hObject,'Visible','off');

% center the figure window on the screen
movegui(hObject, 'center');
handles.mousehold = 0;
handles.toolbar = 0;
%--------------------------------------------------------------------------
% creates the menu File
hmenufile = uimenu('Label','File','Parent',hObject);

% Open submenus
hmenufile_open = uimenu(hmenufile,'Label','Open',...
    'Callback', @menufile_open_callback);

% Load Template submenu
handles.hmenufile_templates(1) = uimenu(hmenufile,...
    'Label','Load Template','Tag',templatedir);

% Create the Load Templates submenus automatically
guidata(hObject,handles);
updatemenutemplate(hObject);
handles = guidata(hObject);

% Load ROIs submenu
hmenufile_roi = uimenu(hmenufile,'Label','Load ROIs',...
    'Callback', @menufile_roiopen_callback);

% Exit submenu
hmenufile_exit = uimenu(hmenufile,'Label','Exit',...
    'Callback', @menufile_exit_callback);

%--------------------------------------------------------------------------
% Create Config Menu
hmenuconfig = uimenu('Label','Config','Parent',hObject);

hmenuconfig_imptpl = uimenu(hmenuconfig,'Label','Import template',...
     'Callback',@menuconfig_imptpl_callback);

hmenuconfig_cleartpl = uimenu(hmenuconfig,...
    'Label','Clear template folder',...
    'Callback',@menuconfig_cleartpl_callback);

hmenuconfig_restoretpl = uimenu(hmenuconfig,...
    'Label','Restore default templates',...
    'Callback',@menuconfig_restoretpl_callback);

hmenuconfig_improifun = uimenu(hmenuconfig,...
    'Label','Import ROI function','Separator','on',...
    'Callback',@menuconfig_improifun_callback);

hmenuconfig_restoreroifun = uimenu(hmenuconfig,...
    'Label','Restore default ROI functions',...
    'Callback',@menuconfig_restoreroifun_callback);

hmenuconfig_imptools = uimenu(hmenuconfig,...
    'Label','Import tools','Separator','on',...
    'Callback',@menuconfig_imptools_callback);

hmenuconfig_restoretools = uimenu(hmenuconfig,...
    'Label','Restore default tools',...
    'Callback',@menuconfig_restoretools);

%--------------------------------------------------------------------------
% Create View menu

hmenuview = uimenu('Label','View','Parent',hObject);

hmenuconfig_dplres = uimenu(hmenuview,'Label','Display resolution',...
    'Callback',@menuconfig_dplres_callback);

hmenuview_showquickguide = uimenu(hmenuview,'Label','Show quick guide',...
    'Callback',@menuhelp_showquickguide_callback);

handles.menuview_showctrlpanel = uimenu(hmenuview,...
    'Label','Show Control Panel','Enable','off',...
    'Callback', @menuhelp_showctrlpanel_callback);


%--------------------------------------------------------------------------
% Create Tools menu
handles.hmenutools = uimenu('Label','Tools','Parent',hObject);

guidata(hObject,handles);
updatemenutools(hObject);
handles = guidata(hObject);

%--------------------------------------------------------------------------
% Create Help menu
hmenuhelp = uimenu('Label','Help','Parent',hObject);

hmenuhelp_about = uimenu(hmenuhelp,'Label','About',...
    'Callback',@menuhelp_about_callback);

hmenuhelp_showquickguide = uimenu(hmenuhelp,'Label','Show quick guide',...
    'Callback',@menuhelp_showquickguide_callback);

hmenuhelp_documentation = uimenu(hmenuhelp,'Label','Documentation',...
    'Callback',@(src,event)web(handles.webdoc));

hmenuhelp_github = uimenu(hmenuhelp,'Label','Github webpage',...
    'Callback',@(src,event)web(handles.github));

%--------------------------------------------------------------------------
% creates the Axes Panel

panelgraph_pos = [.26,.01,.365,.49;...
                  .26,.5,.365,.49;...
                  .625,.5,.365,.49;...
                  .625,.01,.365,.49];

for i = 1:4
    handles.panel_graph(i) = uipanel(hObject,'BackgroundColor','k',...
        'Units','normalized','Visible','on',...
        'Position',panelgraph_pos(i,:));
end

%--------------------------------------------------------------------------
% creates the Control Panel and Welcome panel
panelcontrol_pos = [.01,.01,.24,.98];

handles.panel_logo = uipanel(hObject,'BackgroundColor','w',...
    'Units','normalized','Position',panelcontrol_pos,'Tag','panel_logo');

handles.panel_control = uipanel(hObject,'BackgroundColor','w',...
    'Units','normalized','Position',panelcontrol_pos);

%--------------------------------------------------------------------------
% creates the Welcome text
qgtext = {['Welcome to ',handles.version];...
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
    'https://fmroi-docs.readthedocs.io'};


handles.text_quickguide = uicontrol(handles.panel_logo,'Style','text',...
        'Units','normalized','String',qgtext,...
        'BackgroundColor','w','FontUnits','normalized','FontSize',1/45,...
        'HorizontalAlignment','left','Position',[.01,.35,.98,.64]);

%--------------------------------------------------------------------------
% creates the Logo axis and text

handles.axislogo = axes('Parent',handles.panel_logo,...
    'Box','off','Units','normalized','XTick',[],'YTick',[],...
    'Position',[.2545,.12,.4711,.2000]);
            
imshow(fullfile(fmroirootdir,'etc','figs','fmroi_logo.png'))

set(handles.axislogo,'Tag','axislogo')

logocaption = {'Maintained by members and collaborators of';...
    'Proaction Lab - FPCE, University of Coimbra';...
    'Rua do Colégio Novo - 3001-802 Coimbra, Portugal';...
    'https://proactionlab.fpce.uc.pt'};

handles.textlogo = uicontrol(handles.panel_logo,'Style','text',...
    'Units','normalized','String',logocaption,'FontUnits','normalized',...
    'BackgroundColor','w','FontSize',1/6,'FontAngle','italic',...
    'HorizontalAlignment','center','Position',[.01,.01,.98,.09]);

%--------------------------------------------------------------------------
% creates the Control Panel objects
guidata(hObject,handles);
create_panel_mainctrl(hObject);
handles = guidata(hObject);

set(handles.panel_control,'Visible','off');

%--------------------------------------------------------------------------
% Set the objects to handles

handles.fig = hObject;
handles.tmpdir = tmpdir;
handles.hmenufile = hmenufile;
handles.hmenuhelp = hmenuview;
handles.hsubopen = hmenufile_open;
handles.hsubexit = hmenufile_exit;
handles.config_dir = [];
handles.fss = 1; % font size scale

set(hObject,'Visible','on');

guidata(hObject,handles);

%--------------------------------------------------------------------------
% fMROI internal functions
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
