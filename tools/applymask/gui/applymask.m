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
% Last update: Andre Peres, 06/05/2024, peres.asc@gmail.com
%
%--------------------------------------------------------------------------
%                         runapplymask
%--------------------------------------------------------------------------
%
% runapplymask function applies masks to a set of source images and saves
% the results as time series and statistics.
%
% Syntax:
% function runapplymask(srcpath,maskpath,outdir,opts,hObject)
%
% Inputs:
%   srcpath: Path to the source images (string, cell array of strings, or a 
%            text file containing paths separated by semicolons).
%   maskpath: Path to the mask(s) (string, cell array of strings, or a text 
%            file containing paths separated by semicolons). One mask can 
%            be used for all source images or a separate mask can be  
%            provided for each source image.
%   outdir: Path to the output directory (string).
%   opts (optional): A structure containing options for saving outputs.
%       opts.saveimg (default: 1): Flag indicating if masked images should 
%                      be saved (logical, 1 to save, 0 to not save).
%       opts.savestats (default: 1): Flag indicating if statistics should 
%                      be saved (logical, 1 to save, 0 to not save).
%       opts.savets (default: 1): Flag indicating if time series data 
%                      should be saved (logical, 1 to save, 0 to not save).
%   hObject (optional): Handle to a graphical user interface object 
%                      (not provided for command line usage). 
%
% Outputs: (saved to the output directory)
%   * Masked images (if opts.saveimg is set to 1).
%   * Timeseries.mat file containing the source paths, mask paths, 
%     and time series data (if opts.savets is set to 1).
%   * Median.csv, Mean.csv, Std.csv, Max.csv, Min.csv files containing 
%     statistics for each mask applied to each source image (if 
%     opts.savestats is set to 1).
%
% This function requires SPM to be installed.
%
% Author: Andre Peres, 2024, peres.asc@gmail.com
% Last update: Andre Peres, 06/05/2024, peres.asc@gmail.com


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
handles.tools.applymask.pbutton_run = uicontrol(handles.panel_tools,...
    'Style','PushButton','Units','normalized','String','Run',...
    'FontUnits','normalized','FontSize',fss*.7,...
    'Position',[.6,.21,.2,.12],'Callback',@pbutton_applymaskrun_callback);

% creates save image checkbox
handles.tools.applymask.checkbox_saveimg = uicontrol(handles.panel_tools,...
    'Style','checkbox','Units','normalized','String','Save masked images',...
    'FontUnits','normalized','FontSize',fss*.6,'BackgroundColor','w',...
    'Position',[.01,.32,.5,.08],'Value',1);

% creates save stats checkbox
handles.tools.applymask.checkbox_savestats = uicontrol(handles.panel_tools,...
    'Style','checkbox','Units','normalized','String','Save stats',...
    'FontUnits','normalized','FontSize',fss*.6,'BackgroundColor','w',...
    'Position',[.01,.24,.5,.08],'Value',1);

% creates save time-series checkbox
handles.tools.applymask.checkbox_savets = uicontrol(handles.panel_tools,...
    'Style','checkbox','Units','normalized','String','Save time-series',...
    'FontUnits','normalized','FontSize',fss*.6,'BackgroundColor','w',...
    'Position',[.01,.16,.5,.08],'Value',1);


%==========================================================================
% creates the wait bar
handles.tools.applymask.text_wb = uicontrol(handles.panel_tools,...
    'Style','text','Units','normalized','String','Ready...',...
    'FontUnits','normalized','FontSize',fss*.7,'BackgroundColor','w',...
    'HorizontalAlignment','left','Position',[.01,.07,.98,.07]);

% Java fix due uicontrol missing vertical alignment property
jh = findjobj(handles.tools.applymask.text_wb);
jh.setVerticalAlignment(javax.swing.JLabel.CENTER);

handles.tools.applymask.wb1 = axes(handles.panel_tools,...
    'Units','normalized','Position',[.01,.02,.98,.05],...
    'Xtick',[],'Ytick',[],'Color','w','Box','on');

handles.tools.applymask.wb2 = axes(handles.panel_tools,...
    'Units','normalized','Position',[.01,.02,.0,.05],...
    'Xtick',[],'Ytick',[],'Color','b','Box','on');

guidata(hObject,handles)