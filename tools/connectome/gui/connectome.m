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
% Last update: Andre Peres, 14/05/2025, peres.asc@gmail.com
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
%                 the data can be a table, cell array, or numeric array.
%                 Note that for all supported file types, each row
%                 corresponds to a sample and each column corresponds to
%                 a time stamp:
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
%                    opts.rsave: Save Pearson correlation connectome.
%                    opts.psave: Save p-values connectome.
%                    opts.zsave: Save Fisher transformation connectome.
%                   opts.ftsave: Save feature matrices.
%                       opts.tr: Repetition time (TR) in seconds. Used to 
%                                compute the sampling frequency for 
%                                filtering.
%                 opts.highpass: High-pass filter cutoff frequency in Hz. 
%                                Can be a numeric value or the string 
%                                'none'. If a numeric value is given, a 
%                                first-order Butterworth high-pass or 
%                                band-pass filter is applied depending
%                                on whether opts.lowpass is also set.
%                  opts.lowpass: Low-pass filter cutoff frequency in Hz. 
%                                Can be a numeric value or the string 
%                                'none'. If a numeric value is given, a 
%                                first-order Butterworth low-pass or 
%                                band-pass filter is applied depending
%                                on whether opts.highpass is also set.
%
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
% Last update: Andre Peres, 14/05/2025, peres.asc@gmail.com

delete_panel_tools(hObject)
create_panel_tools(hObject)

handles = guidata(hObject);
set(handles.panel_control,'Visible','on');

fss = handles.fss; % font size scale
x = 0;
y = 0.02;


%--------------------------------------------------------------------------
% Set the string in the title bar
set(handles.text_toolstitlebar,'string','Connectome')

%==========================================================================
% creates the text for time-series path
handles.tools.connectome.text_tspath = uicontrol(handles.panel_tools,...
    'Style','text','Units','normalized','String','Time-series path:',...
    'FontUnits','normalized','FontSize',fss*.7,'BackgroundColor','w',...
    'HorizontalAlignment','left','Position',[.01+x,.8+y,.4,.08]);

% Java fix due uicontrol missing vertical alignment property
jh = findjobj(handles.tools.connectome.text_tspath);
jh.setVerticalAlignment(javax.swing.JLabel.CENTER);

%--------------------------------------------------------------------------
% creates the edit text for source path
handles.tools.connectome.edit_tspath = uicontrol(handles.panel_tools,...
    'Style','edit','Units','normalized','BackgroundColor','w',...
    'String','','FontUnits','normalized','FontSize',fss*.7,...
    'HorizontalAlignment','left','Position',[.01+x,.73+y,.92,.07]);

%--------------------------------------------------------------------------
% creates the source uigetfile pushbutton
handles.tools.connectome.pbutton_tspath = uicontrol(handles.panel_tools,...
    'Style','PushButton','Units','normalized','String','...',...
    'FontUnits','normalized','FontSize',fss*.7,...
    'Position',[.935+x,.73+y,.055,.07],...
    'Callback',@pbutton_connectomeselectfiles_callback);

%==========================================================================
% creates the text for ROI names path
handles.tools.connectome.text_roinamepath = uicontrol(handles.panel_tools,...
    'Style','text','Units','normalized','String','ROI names:',...
    'FontUnits','normalized','FontSize',fss*.7,'BackgroundColor','w',...
    'HorizontalAlignment','left','Position',[.01+x,.65+y,.4,.08]);

% Java fix due uicontrol missing vertical alignment property
jh = findjobj(handles.tools.connectome.text_roinamepath);
jh.setVerticalAlignment(javax.swing.JLabel.CENTER);
        
%--------------------------------------------------------------------------
% creates the edit text for mask path
handles.tools.connectome.edit_roinamepath = uicontrol(handles.panel_tools,...
    'Style','edit','Units','normalized','BackgroundColor','w',...
    'String','','FontUnits','normalized','FontSize',fss*.7,...
    'HorizontalAlignment','left','Position',[.01+x,.58+y,.92,.07]);

%--------------------------------------------------------------------------
% creates the mask uigetfile pushbutton
handles.tools.connectome.pbutton_roinamepath = uicontrol(handles.panel_tools,...
    'Style','PushButton','Units','normalized','String','...',...
    'FontUnits','normalized','FontSize',fss*.7,...
    'Position',[.935+x,.58+y,.055,.07],...
    'Callback',@pbutton_connectomeselectfiles_callback);

%==========================================================================
% creates the text for output path
handles.tools.connectome.text_outdir = uicontrol(handles.panel_tools,...
    'Style','text','Units','normalized','String','Output folder:',...
    'FontUnits','normalized','FontSize',fss*.7,'BackgroundColor','w',...
    'HorizontalAlignment','left','Position',[.01+x,.5+y,.4,.08]);

% Java fix due uicontrol missing vertical alignment property
jh = findjobj(handles.tools.connectome.text_outdir);
jh.setVerticalAlignment(javax.swing.JLabel.CENTER);
        
%--------------------------------------------------------------------------
% creates the edit text for output path
handles.tools.connectome.edit_outdir = uicontrol(handles.panel_tools,...
    'Style','edit','Units','normalized','BackgroundColor','w',...
    'String',pwd,'FontUnits','normalized','FontSize',fss*.7,...
    'HorizontalAlignment','left','Position',[.01+x,.43+y,.92,.07]);

%--------------------------------------------------------------------------
% creates the output uiputfile pushbutton
handles.tools.connectome.pbutton_outdir = uicontrol(handles.panel_tools,...
    'Style','PushButton','Units','normalized','String','...',...
    'FontUnits','normalized','FontSize',fss*.7,...
    'Position',[.935+x,.43+y,.055,.07],...
    'Callback',@pbutton_connectomeselectfiles_callback);

% %==========================================================================
% creates the options checkboxes

% creates save r checkbox
handles.tools.connectome.checkbox_rsave = uicontrol(handles.panel_tools,...
    'Style','checkbox','Units','normalized','String','Save Pearson coef',...
    'FontUnits','normalized','FontSize',fss*.6,'BackgroundColor','w',...
    'Position',[.01+x,.32+y,.5,.08],'Value',1);

% creates save p checkbox
handles.tools.connectome.checkbox_psave = uicontrol(handles.panel_tools,...
    'Style','checkbox','Units','normalized','String','Save p-values',...
    'FontUnits','normalized','FontSize',fss*.6,'BackgroundColor','w',...
    'Position',[.01+x,.24+y,.5,.08],'Value',1);

% creates save z checkbox
handles.tools.connectome.checkbox_zsave = uicontrol(handles.panel_tools,...
    'Style','checkbox','Units','normalized','String','Save Fisher transform',...
    'FontUnits','normalized','FontSize',fss*.6,'BackgroundColor','w',...
    'Position',[.01+x,.16+y,.5,.08],'Value',1);

% creates save ft checkbox
handles.tools.connectome.checkbox_ftsave = uicontrol(handles.panel_tools,...
    'Style','checkbox','Units','normalized','String','Save feat matrix',...
    'FontUnits','normalized','FontSize',fss*.6,'BackgroundColor','w',...
    'Position',[.01+x,.08+y,.5,.08],'Value',1);

% %==========================================================================
% % creates the text for high-pass filter
% handles.tools.connectome.text_highpass = uicontrol(handles.panel_tools,...
%     'Style','text','Units','normalized','String','High-pass (Hz):',...
%     'FontUnits','normalized','FontSize',fss*.6,'BackgroundColor','w',...
%     'HorizontalAlignment','center','Position',[.01+x,y-.01,.29,.08]);
% 
% % Java fix due uicontrol missing vertical alignment property
% jh = findjobj(handles.tools.connectome.text_highpass);
% jh.setVerticalAlignment(javax.swing.JLabel.CENTER);
% 
% %--------------------------------------------------------------------------
% % creates the edit text for high-pass filter
% handles.tools.connectome.edit_highpass = uicontrol(handles.panel_tools,...
%     'Style','edit','Units','normalized','BackgroundColor','w',...
%     'String','none','FontUnits','normalized','FontSize',fss*.6,...
%     'HorizontalAlignment','center','Position',[.3+x,y-.01,.2,.08]);
% 
% %==========================================================================
% % creates the text for Loww-pass filter
% handles.tools.connectome.text_lowpass = uicontrol(handles.panel_tools,...
%     'Style','text','Units','normalized','String','Low-pass (Hz):',...
%     'FontUnits','normalized','FontSize',fss*.6,'BackgroundColor','w',...
%     'HorizontalAlignment','center','Position',[.51+x,y-.01,.29,.08]);
% 
% % Java fix due uicontrol missing vertical alignment property
% jh = findjobj(handles.tools.connectome.text_lowpass);
% jh.setVerticalAlignment(javax.swing.JLabel.CENTER);
% 
% %--------------------------------------------------------------------------
% % creates the edit text for low-pass filter
% handles.tools.connectome.edit_lowpass = uicontrol(handles.panel_tools,...
%     'Style','edit','Units','normalized','BackgroundColor','w',...
%     'String','none','FontUnits','normalized','FontSize',fss*.6,...
%     'HorizontalAlignment','center','Position',[.8+x,y-.01,.19,.08]);
% 
% %==========================================================================
% % creates the text for TR
% handles.tools.connectome.text_tr = uicontrol(handles.panel_tools,...
%     'Style','text','Units','normalized','String','TR (s):',...
%     'FontUnits','normalized','FontSize',fss*.6,'BackgroundColor','w',...
%     'HorizontalAlignment','center','Position',[.51+x,.08+y,.29,.08]);
% 
% % Java fix due uicontrol missing vertical alignment property
% jh = findjobj(handles.tools.connectome.text_tr);
% jh.setVerticalAlignment(javax.swing.JLabel.CENTER);
% 
% %--------------------------------------------------------------------------
% % creates the edit text for TR
% handles.tools.connectome.edit_tr = uicontrol(handles.panel_tools,...
%     'Style','edit','Units','normalized','BackgroundColor','w',...
%     'String','1','FontUnits','normalized','FontSize',fss*.6,...
%     'HorizontalAlignment','center','Position',[.8+x,.08+y,.19,.08]);

%==========================================================================
% creates the run pushbutton
handles.tools.connectome.pbutton_run = uicontrol(handles.panel_tools,...
    'Style','PushButton','Units','normalized','String','Run',...
    'FontUnits','normalized','FontSize',fss*.5,...
    'Position',[.51+x,.28+y,.225,.12],'Callback',@pbutton_runconnectome_callback);

% [.51,.26,.22,.12]

%==========================================================================
% creates the settings pushbutton
handles.tools.connectome.pbutton_settings = uicontrol(handles.panel_tools,...
    'Style','PushButton','Units','normalized','String','Settings',...
    'FontUnits','normalized','FontSize',fss*.5,...
    'Position',[.76+x,.28+y,.225,.12],'Callback',@pbutton_connectomesettings_callback);

%==========================================================================
% creates the progress text box
handles.tools.connectome.text_wb = uicontrol(handles.panel_tools,...
    'Style','text','Units','normalized','String','Ready...',...
    'FontUnits','normalized','FontSize',fss*.7,'BackgroundColor','w',...
    'HorizontalAlignment','left','Position',[.62+x,.18+y,.25,.08]);

% Java fix due uicontrol missing vertical alignment property
jh = findjobj(handles.tools.connectome.text_wb);
jh.setVerticalAlignment(javax.swing.JLabel.CENTER);

guidata(hObject,handles)