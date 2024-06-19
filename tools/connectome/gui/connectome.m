function connectome(hObject,~)
% connectome is an internal function of fMROI. This function cretes 
% connectomes from time-series and performs statical analysis. For more 
% information refer to the function runconnectome.m.
%
% Syntax:
%   connectome(hObject,~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2024, peres.asc@gmail.com
% Last update: Andre Peres, 06/05/2024, peres.asc@gmail.com
%
%--------------------------------------------------------------------------
%                        runconnectome header
%--------------------------------------------------------------------------
%
% runconnectome computes Pearson correlation coefficients, p-values, and
% Fisher transformation connectomes from input time-series data and saves
% the results in specified output directories. Optionally, it can save the
% results as feature matrices for machine-learning use.
%
%
% Inputs:
%         tspath: Path(s) to the time-series data file(s). Supported 
%                 formats are .mat, .txt, .csv, and .tsv. For .mat files, 
%                 the data can be a table, cell array, or numeric array:
%                    - If a Matlab table, it must have a variable named as
%                      "timeseries" from where the time-series are
%                      extracted and stored in a cell array. Time-series 
%                      within each cell is processed separately, resulting 
%                      in as many connectomes as the number of cells.
%                      It is possible to obtain this table directly from 
%                      the applymask algorithm (fmroi/tools).
%                    - If a cell array, each time-series within each cell
%                      is processed separately, resulting in as many 
%                      connectomes as the number of cells.
%                    - If a numeric array (matrix) or any other file type,
%                      a single connectome is generated for all the
%                      time-series, treating them as from the same subject.
%         outdir: Directory where the output files will be saved.
%   roinamespath: (Optional) Path to the file containing ROI names.
%                 Supported formats are .mat, .txt, .csv, and .tsv.
%                 The file must have the same length as the number of
%                 time-series. Each ROI name in roinamespath corresponds
%                 to the ROI from which each time-series was extracted.
%                 If not provided, generic names will be assigned.
%           opts: (Optional - default: 1) Structure containing options:
%                     opts.rsave: Save Pearson correlation connectome.
%                     opts.psave: Save p-values connectome.
%                     opts.zsave: Save Fisher transformation connectome.
%                    opts.ftsave: Save feature matrices. 
%        hObject: (Optional - default: NaN) Handle to the graphical user 
%                 interface object. Not provided for command line usage.
%
% Outputs:
%   The runconnectome saves the computed connectomes and feature matrices 
%   in the specified output directory. The filenames include 'rconnec.mat', 
%   'pconnec.mat', 'zconnec.mat', and their corresponding feature matrices
%   as 'rfeatmat.mat', 'pfeatmat.mat', 'zfeatmat.mat', and their CSV 
%   versions.
%
% Author: Andre Peres, 2024, peres.asc@gmail.com
% Last update: Andre Peres, 15/05/2024, peres.asc@gmail.com

delete_panel_tools(hObject)
create_panel_tools(hObject)

handles = guidata(hObject);
set(handles.panel_control,'Visible','on');

fss = handles.fss; % font size scale

%--------------------------------------------------------------------------
% Set the string in the title bar
set(handles.text_toolstitlebar,'string','Connectome')

%==========================================================================
% creates the text for time-series path
handles.tools.connectome.text_tspath = uicontrol(handles.panel_tools,...
    'Style','text','Units','normalized','String','Time-series path:',...
    'FontUnits','normalized','FontSize',fss*.7,'BackgroundColor','w',...
    'HorizontalAlignment','left','Position',[.01,.8,.4,.08]);

% Java fix due uicontrol missing vertical alignment property
jh = findjobj(handles.tools.connectome.text_tspath);
jh.setVerticalAlignment(javax.swing.JLabel.CENTER);

%--------------------------------------------------------------------------
% creates the edit text for source path
handles.tools.connectome.edit_tspath = uicontrol(handles.panel_tools,...
    'Style','edit','Units','normalized','BackgroundColor','w',...
    'String','','FontUnits','normalized','FontSize',fss*.7,...
    'HorizontalAlignment','left','Position',[.01,.73,.92,.07]);

%--------------------------------------------------------------------------
% creates the source uigetfile pushbutton
handles.tools.connectome.pbutton_tspath = uicontrol(handles.panel_tools,...
    'Style','PushButton','Units','normalized','String','...',...
    'FontUnits','normalized','FontSize',fss*.7,...
    'Position',[.935,.73,.055,.07],...
    'Callback',@pbutton_connectomeselectfiles_callback);

%==========================================================================
% creates the text for ROI names path
handles.tools.connectome.text_roinamepath = uicontrol(handles.panel_tools,...
    'Style','text','Units','normalized','String','ROI names:',...
    'FontUnits','normalized','FontSize',fss*.7,'BackgroundColor','w',...
    'HorizontalAlignment','left','Position',[.01,.65,.4,.08]);

% Java fix due uicontrol missing vertical alignment property
jh = findjobj(handles.tools.connectome.text_roinamepath);
jh.setVerticalAlignment(javax.swing.JLabel.CENTER);
        
%--------------------------------------------------------------------------
% creates the edit text for mask path
handles.tools.connectome.edit_roinamepath = uicontrol(handles.panel_tools,...
    'Style','edit','Units','normalized','BackgroundColor','w',...
    'String','','FontUnits','normalized','FontSize',fss*.7,...
    'HorizontalAlignment','left','Position',[.01,.58,.92,.07]);

%--------------------------------------------------------------------------
% creates the mask uigetfile pushbutton
handles.tools.connectome.pbutton_roinamepath = uicontrol(handles.panel_tools,...
    'Style','PushButton','Units','normalized','String','...',...
    'FontUnits','normalized','FontSize',fss*.7,...
    'Position',[.935,.58,.055,.07],...
    'Callback',@pbutton_connectomeselectfiles_callback);

%==========================================================================
% creates the text for output path
handles.tools.connectome.text_outdir = uicontrol(handles.panel_tools,...
    'Style','text','Units','normalized','String','Output folder:',...
    'FontUnits','normalized','FontSize',fss*.7,'BackgroundColor','w',...
    'HorizontalAlignment','left','Position',[.01,.5,.4,.08]);

% Java fix due uicontrol missing vertical alignment property
jh = findjobj(handles.tools.connectome.text_outdir);
jh.setVerticalAlignment(javax.swing.JLabel.CENTER);
        
%--------------------------------------------------------------------------
% creates the edit text for output path
handles.tools.connectome.edit_outdir = uicontrol(handles.panel_tools,...
    'Style','edit','Units','normalized','BackgroundColor','w',...
    'String',pwd,'FontUnits','normalized','FontSize',fss*.7,...
    'HorizontalAlignment','left','Position',[.01,.43,.92,.07]);

%--------------------------------------------------------------------------
% creates the output uiputfile pushbutton
handles.tools.connectome.pbutton_outdir = uicontrol(handles.panel_tools,...
    'Style','PushButton','Units','normalized','String','...',...
    'FontUnits','normalized','FontSize',fss*.7,...
    'Position',[.935,.43,.055,.07],...
    'Callback',@pbutton_connectomeselectfiles_callback);

%==========================================================================
% creates the run pushbutton
handles.tools.connectome.pbutton_run = uicontrol(handles.panel_tools,...
    'Style','PushButton','Units','normalized','String','Run',...
    'FontUnits','normalized','FontSize',fss*.7,...
    'Position',[.62,.26,.2,.12],'Callback',@pbutton_runconnectome_callback);

% %==========================================================================
% creates the options checkboxes

% creates save r checkbox
handles.tools.connectome.checkbox_rsave = uicontrol(handles.panel_tools,...
    'Style','checkbox','Units','normalized','String','Save Pearson coef',...
    'FontUnits','normalized','FontSize',fss*.6,'BackgroundColor','w',...
    'Position',[.01,.32,.5,.08],'Value',1);

% creates save p checkbox
handles.tools.connectome.checkbox_psave = uicontrol(handles.panel_tools,...
    'Style','checkbox','Units','normalized','String','Save p-values',...
    'FontUnits','normalized','FontSize',fss*.6,'BackgroundColor','w',...
    'Position',[.01,.24,.5,.08],'Value',1);

% creates save z checkbox
handles.tools.connectome.checkbox_zsave = uicontrol(handles.panel_tools,...
    'Style','checkbox','Units','normalized','String','Save Fisher transform',...
    'FontUnits','normalized','FontSize',fss*.6,'BackgroundColor','w',...
    'Position',[.01,.16,.5,.08],'Value',1);

% creates save ft checkbox
handles.tools.connectome.checkbox_ftsave = uicontrol(handles.panel_tools,...
    'Style','checkbox','Units','normalized','String','Save feat matrix',...
    'FontUnits','normalized','FontSize',fss*.6,'BackgroundColor','w',...
    'Position',[.01,.08,.5,.08],'Value',1);


%==========================================================================
% creates the wait bar
handles.tools.connectome.text_wb = uicontrol(handles.panel_tools,...
    'Style','text','Units','normalized','String','Ready...',...
    'FontUnits','normalized','FontSize',fss*.7,'BackgroundColor','w',...
    'HorizontalAlignment','left','Position',[.62,.14,.25,.08]);

% Java fix due uicontrol missing vertical alignment property
jh = findjobj(handles.tools.connectome.text_wb);
jh.setVerticalAlignment(javax.swing.JLabel.CENTER);

guidata(hObject,handles)