function getopts(hObject,~)

handles = guidata(hObject);

handles.opts.filter = [];
handles.opts.regout = [];
handles.opts.smooth = [];
handles.opts.zscore = [];

%==========================================================================
% Retrieve Filter options
if get(handles.tools.settings.checkbox_butter,'Value')
    handles.opts.filter.tr = get(handles.tools.settings.edit_tr,'string');
    handles.opts.filter.highpass = get(handles.tools.settings.edit_highpass,'string');
    handles.opts.filter.lowpass = get(handles.tools.settings.edit_lowpass,'string');
    handles.opts.filter.order = get(handles.tools.settings.edit_filterorder,'string');

    %--------------------------------------------------------------------------
    % Convert handles.opts.filter.tr to double
    try
        handles.opts.filter.tr = str2double(handles.opts.filter.tr);

        if ~isscalar(handles.opts.filter.tr) || isnan(handles.opts.filter.tr)
            he = errordlg({'Invalid TR value format!',...
                'The TR value must be a scalar expressed in seconds.'},...
                'Invalid Input');
            uiwait(he)
            return
        end

    catch
        he = errordlg({'Invalid TR value format!',...
            'The TR value must be a scalar expressed in seconds.'},...
            'Invalid Input');
        uiwait(he)
        return
    end


    %--------------------------------------------------------------------------
    % Convert handles.opts.filter.highpass to double
    if strcmpi(handles.opts.filter.highpass,'none')
        handles.opts.filter.highpass = [];
    else
        try
            handles.opts.filter.highpass = str2double(handles.opts.filter.highpass);

            if ~isscalar(handles.opts.filter.highpass) || isnan(handles.opts.filter.highpass)
                he = errordlg({'Invalid high-pass value format!',...
                    'The high-pass value must be scalar expressed in hertz.'},...
                    'Invalid Input');
                uiwait(he)
                return
            end

        catch
            he = errordlg({'Invalid high-pass value format!',...
                'The high-pass value must be scalar expressed in hertz.'},...
                'Invalid Input');
            uiwait(he)
            return
        end
    end

    

    %--------------------------------------------------------------------------
    % Convert handles.opts.filter.lowpass to double
    if strcmpi(handles.opts.filter.lowpass,'none')
        handles.opts.filter.lowpass = [];
    else
        try
            handles.opts.filter.lowpass = str2double(handles.opts.filter.lowpass);
            
            if ~isscalar(handles.opts.filter.lowpass) || isnan(handles.opts.filter.lowpass)
                he = errordlg({'Invalid low-pass value format!',...
                    'The low-pass value must be scalar expressed in hertz.'},...
                    'Invalid Input');
                uiwait(he)
                return
            end

        catch
            he = errordlg({'Invalid low-pass value format!',...
                'The low-pass value must be scalar expressed in hertz.'},...
                'Invalid Input');
            uiwait(he)
            return
        end
    end    

    %--------------------------------------------------------------------------
    % Convert handles.opts.filter.order to double
    
    try
        handles.opts.filter.order = str2double(handles.opts.filter.order);

        if ~isscalar(handles.opts.filter.order) ||...
                isnan(handles.opts.filter.order) ||...
                handles.opts.filter.order < 1 ||...
                handles.opts.filter.order > 500 ||...
                ~mod(handles.opts.filter.order,1) == 0

            he = errordlg({'Invalid filter order value format!',...
            'The filter order must be an integer from 1 to 500.'},...
            'Invalid Input');
            uiwait(he)
            return
        end
        handles.opts.filter.order = round(handles.opts.filter.order);

    catch
        he = errordlg({'Invalid filter order value format!',...
            'The filter order must be an integer from 1 to 500.'},...
            'Invalid Input');
        uiwait(he)
        return
    end
end
%==========================================================================
% Retrieve GLM Regress Out options

if handles.tools.settings.checkbox_regressout.Value

    % load the confounds path
    confpath = get(handles.tools.settings.edit_confoundspath,'string');
    
    % load the demean option
    handles.opts.regout.demean = get(handles.tools.settings.checkbox_demean,'Value');

    if ~isfile(confpath) && ~handles.opts.regout.demean
        he = errordlg('Invalid confounds path!');
        uiwait(he)
        return
    end
    
    if isfile(confpath)
        [~,~,ext] = fileparts(confpath);

        if strcmpi(ext,'.mat')
            auxconf = load(confpath);
            varname = fieldnames(auxconf);
            handles.opts.regout.conf = auxconf.(varname{1});
            if istable(handles.opts.regout.conf)
                handles.opts.regout.conf = table2array(handles.opts.regout.conf);
            end
        elseif strcmpi(ext,'.txt') || strcmpi(ext,'.csv') || strcmpi(ext,'.tsv')
            handles.opts.regout.conf = readmatrix(confpath);            
        else
            he = errordlg('Invalid file format!');
            uiwait(he)
            return
        end
        handles.opts.regout.conf = nan2num(handles.opts.regout.conf);
    else
        handles.opts.regout.conf = [];
    end

    %--------------------------------------------------------------------------
    % load the selected confounds columns
    selconfpath = get(handles.tools.settings.edit_selconf,'string');

    if isfile(selconfpath)
        [~,~,ext] = fileparts(selconfpath);

        if strcmpi(ext,'.mat')
            auxselconf = load(selconfpath);
            varname = fieldnames(auxselconf);
            handles.opts.regout.selconf = auxselconf.(varname{1});
        elseif strcmpi(ext,'.txt') || strcmpi(ext,'.csv') || strcmpi(ext,'.tsv')
            handles.opts.regout.selconf = readmatrix(selconfpath);
        else
            he = errordlg('Invalid file format!');
            uiwait(he)
            return
        end
    else
        try
            handles.opts.regout.selconf = eval(['[',handles.tools.settings.edit_selconf.String,']']);
        catch
            handles.opts.regout.selconf = [];
        end
    end

    if ~isempty(handles.opts.regout.selconf)

        handles.opts.regout.selconf = round(handles.opts.regout.selconf);
        if ~isvector(handles.opts.regout.selconf)
            he = errordlg('The selected confound indices must be provided as a vector.', ...
                'Invalid Input');
            uiwait(he)
            return
        end

        if ~isrow(handles.opts.regout.selconf)
            handles.opts.regout.selconf = handles.opts.regout.selconf';
        end

        maxsc = max(handles.opts.regout.selconf);
        minsc = min(handles.opts.regout.selconf);
        
        n_conf_cols = size(handles.opts.regout.conf,2);  % número total de colunas em conf

        if minsc < 1 || maxsc > n_conf_cols
            he = errordlg('Invalid indices for selecting columns from the confound matrix.', ...
                'Index Out of Bounds');
            uiwait(he)
            return
        end
    end
end

%==========================================================================
% Retrieve Smooth options
if get(handles.tools.settings.checkbox_smooth,'Value')
    handles.opts.smooth.fwhm = get(handles.tools.settings.edit_smooth,'string');
   
    %--------------------------------------------------------------------------
    % Convert handles.opts.smooth.fwhm to double
    try
        handles.opts.smooth.fwhm = eval(['[',handles.opts.smooth.fwhm,']']);

        if isnan(handles.opts.smooth.fwhm)
            he = errordlg({'Invalid FHHM value format!',...
                'The FHHM value must be numeric (scalar or 1x3 vector).'},...
                'Invalid Input');
            uiwait(he)
            return
        end

    catch
        he = errordlg({'Invalid FHHM value format!',...
            'The FHHM value must be numeric (scalar or 1x3 vector).'},...
            'Invalid Input');
        uiwait(he)
        return
    end
end

%==========================================================================
% Retrieve Smooth options
handles.opts.zscore = get(handles.tools.settings.checkbox_zscore,'Value');


guidata(hObject,handles)

delete_panel_settings(hObject)