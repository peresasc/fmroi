function applymask(hObject,~)
% applymask is an internal function of fMROI. This function cretaes the GUI
% for applying masks to fMRI images. For more information refer to the
% function runapplymask.m.
%
% Syntax:
%   applymask(hObject,~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2024, peres.asc@gmail.com
% Last update: Andre Peres, 28/05/2025, peres.asc@gmail.com
%
%--------------------------------------------------------------------------
%                         runapplymask header
%--------------------------------------------------------------------------
%
% runapplymask function applies one or more masks to a set of fMRI images
% defined in SRCPATH and computes summary statistics and/or time series 
% data for each mask. Optional preprocessing can also be applied to the
% time series data prior to extraction.
%
% Syntax:
% function runapplymask(srcpath,maskpath,outdir,opts,hObject)
%
% Inputs:
%    srcpath: String containg the paths to the source images separeted by
%             semicolons, or a path to a text file (.txt, .csv, or .tsv) 
%             containing the images paths in a line (separated by tabs or
%             semicolons) or in a column (1D array).
%
%   maskpath: String containg the paths to the mask images separeted by
%             semicolons, or a path to a text file (.txt, .csv, or .tsv) 
%             containing the maskpaths paths separated by tabs or
%             semicolons. The number of mask paths must exactly match the 
%             number of source images or there can be only one mask. Each
%             mask in the list is applied to the corresponding source image
%             in the same order (i.e., first mask to first image, second 
%             mask to second image, and so on). If the maskpath points to a
%             text file, each column represents a different mask type and
%             will be processed separately. Each column can have as many
%             lines as there are source images or only one mask to be
%             applied to all images.
%
%     outdir: Path to the output directory (string).
%
%       opts: Structure with optional settings including preprocessing
%                   steps and output options. The following fields are
%                   supported:
%
%                            *** Saving data ***
%
%           opts.saveimg: (default: 0) Flag indicating if masked images 
%                         should be saved (logical, 1 to save, 0 to not
%                         save).
%         opts.savestats: (default: 1) Flag indicating if statistics should
%                         be saved (logical, 1 to save, 0 to not save), the 
%                         saved stats are mean, meadian, standard 
%                         deviation, maximum value, and minimum valeu for 
%                         each subject and ROI.
%            opts.savets: (default: 1) Flag indicating if time series data
%                         should be saved (logical, 1 to save, 0 to not
%                         save).
%           opts.groupts: (default: 0) Flag used to control how the time
%                         series data is saved. If opts.groupts is set to
%                         1, then the time series data will be saved 
%                         grouped by source image. This means that all 
%                         of the time series for a particular source image 
%                         will be saved together in a single file. However,
%                         if opts.groupts is set to 0, then the time series
%                         data for will be saved for each mask separately.
%                         This means that there will be a separate file
%                         for each mask.
%
%                            *** Cleaning data ***
%
%         opts.filter.tr: Repetition time (TR) in seconds. Used to compute 
%                         the sampling frequency for filtering.
%   opts.filter.highpass: High-pass cutoff frequency in Hz. Can be a 
%                         numeric value or the string 'none'. If numeric, 
%                         a Butterworth filter is applied.
%    opts.filter.lowpass: Low-pass cutoff frequency in Hz. Can be a 
%                         numeric value or the string 'none'. If numeric, 
%                         a Butterworth filter is applied.
%      opts.filter.order: (Optional, default = 1) Order of the Butterworth 
%                         filter. Applies to high-pass, low-pass, or 
%                         band-pass designs.
%
%       opts.regout.conf: Table, matrix, or cell array of confound files 
%                         (numeric or table) to be regressed out via 
%                         GLM. If multiple subjects are processed, must 
%                         be a cell array with one entry per subject.
%    opts.regout.selconf: Vector of column indices to select specific 
%                         confounds from `conf`. Can be empty to use 
%                         all columns.
%     opts.regout.demean: Logical flag (default: false) indicating whether 
%                         to include a constant (intercept) regressor 
%                         for mean removal during regression.
%
%       opts.smooth.fwhm: Full width at half maximum (FWHM) of the 
%                            spatial Gaussian kernel in mm (scalar).
%
%            opts.zscore: Logical flag. If true, the time series of each 
%                         voxel is z-scored (zero mean, unit std) after
%                         all other preprocessing steps.
%
%    hObject: (Optional - default: NaN) Handle to the graphical user 
%             interface object. Not provided for command line usage.
%
% Outputs: runapplymask saves to the output directory the following data:
%   * Masked images (if opts.saveimg is set to 1).
%   * Timeseries.mat file containing the source paths, mask paths,
%     and time series data (if opts.savets is set to 1).
%   * Median.csv, Mean.csv, Std.csv, Max.csv, Min.csv files containing
%     statistics for each mask applied to each source image (if
%     opts.savestats is set to 1).
%
% This function requires SPM12 to be installed.
%
% Author: Andre Peres, 2024, peres.asc@gmail.com
% Last update: Andre Peres, 04/12/2025, peres.asc@gmail.com

delete_panel_settings(hObject)
delete_panel_tools(hObject)
create_panel_tools(hObject)

handles = guidata(hObject);
set(handles.panel_control,'Visible','on');

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
uicontrol_textalign(handles.tools.applymask.text_srcpath);

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
uicontrol_textalign(handles.tools.applymask.text_maskpath);
        
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
uicontrol_textalign(handles.tools.applymask.text_outdir);
        
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
handles.tools.applymask.pbutton_run = uicontrol(handles.panel_tools,...
    'Style','PushButton','Units','normalized','String','Run',...
    'FontUnits','normalized','FontSize',fss*.5,...
    'Position',[.51,.26,.225,.12],'Callback',@pbutton_applymaskrun_callback);

%==========================================================================
% creates the settings pushbutton
handles.tools.applymask.pbutton_settings = uicontrol(handles.panel_tools,...
    'Style','PushButton','Units','normalized','String','Settings',...
    'FontUnits','normalized','FontSize',fss*.5,...
    'Position',[.76,.26,.225,.12],'Callback',@pbutton_applymasksettings_callback);

%==========================================================================
% creates the options checkboxes

% creates save image checkbox
handles.tools.applymask.checkbox_saveimg = uicontrol(handles.panel_tools,...
    'Style','checkbox','Units','normalized','String','Save masked images',...
    'FontUnits','normalized','FontSize',fss*.6,'BackgroundColor','w',...
    'Position',[.01,.32,.5,.08],'Value',0,'TooltipString',...
    'May significantly increase RAM usage!');

% creates save stats checkbox
handles.tools.applymask.checkbox_savestats = uicontrol(handles.panel_tools,...
    'Style','checkbox','Units','normalized','String','Save stats',...
    'FontUnits','normalized','FontSize',fss*.6,'BackgroundColor','w',...
    'Position',[.01,.24,.5,.08],'Value',1);

% creates save time-series checkbox
handles.tools.applymask.checkbox_savets = uicontrol(handles.panel_tools,...
    'Style','checkbox','Units','normalized','String','Save time-series',...
    'FontUnits','normalized','FontSize',fss*.6,'BackgroundColor','w',...
    'Position',[.01,.16,.5,.08],'Value',1,...
    'Callback',@checkbox_savets_callback);

% creates group time-series checkbox
handles.tools.applymask.checkbox_groupts = uicontrol(handles.panel_tools,...
    'Style','checkbox','Units','normalized','String','Group srcimg tseries',...
    'FontUnits','normalized','FontSize',fss*.6,'BackgroundColor','w',...
    'Position',[.51,.16,.48,.08],'Value',0);


%==========================================================================
% creates the wait bar
handles.tools.applymask.text_wb = uicontrol(handles.panel_tools,...
    'Style','text','Units','normalized','String','Ready...',...
    'FontUnits','normalized','FontSize',fss*.7,'BackgroundColor','w',...
    'HorizontalAlignment','left','Position',[.01,.07,.98,.07]);

% Java fix due uicontrol missing vertical alignment property
uicontrol_textalign(handles.tools.applymask.text_wb);

handles.tools.applymask.wb1 = axes(handles.panel_tools,...
    'Units','normalized','Position',[.01,.02,.98,.05],...
    'Xtick',[],'Ytick',[],'Color','w','Box','on');

handles.tools.applymask.wb2 = axes(handles.panel_tools,...
    'Units','normalized','Position',[.01,.02,0,.05],...
    'Xtick',[],'Ytick',[],'Color','b','Box','on');

guidata(hObject,handles)