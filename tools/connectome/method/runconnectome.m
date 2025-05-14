function runconnectome(tspath,outdir,roinamespath,opts,hObject)
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


if nargin < 2
    he = errordlg('Not enought input arguments!');
    uiwait(he)
    return
elseif nargin == 2
    roinamespath = [];
    opts.rsave = 1;
    opts.psave = 1;
    opts.zsave = 1;
    opts.ftsave = 1;
    opts.tr = 1;
    opts.highpass = 'none';
    opts.lowpass = 'none';
    hObject = nan;
elseif nargin == 3
    opts.rsave = 1;
    opts.psave = 1;srcvol
    opts.zsave = 1;
    opts.ftsave = 1;
    opts.tr = 1;
    opts.highpass = 'none';
    opts.lowpass = 'none';
    hObject = nan;
elseif nargin == 4
    hObject = nan;
else
    handles = guidata(hObject);
end

%--------------------------------------------------------------------------
% Convert opts.tr to double
if isnumeric(opts.tr) && isscalar(opts.tr)
    tr = double(opts.tr);
    disp(['TR equal to ',num2str(tr),' s.']);

elseif ischar(opts.tr)
    tr = str2double(opts.tr);

    if isnan(tr)
        tr = 1;
        disp(['Warning: Invalid TR value format. ',...
            'TR set to ',num2str(tr),' s.']);
    else
        disp(['TR equal to ',num2str(tr),' s.']);
    end

else
    tr = 1;
    disp(['Warning: Invalid TR value format. ',...
        'TR set to ',num2str(tr),' s.']);
end

%--------------------------------------------------------------------------
% Convert opts.highpass to double
if isnumeric(opts.highpass) && isscalar(opts.highpass)
    hp = double(opts.highpass);
    disp(['High-pass filter of ',num2str(hp),' Hz will be applied.']);

elseif ischar(opts.highpass)
    hp = str2double(opts.highpass);

    if strcmpi(opts.highpass,'none')
        disp('Warning: High-pass filter will not be applied.');
    elseif isnan(hp)
        disp(['Warning: Invalid High-pass filter value format. ',...
            'No filter will be applied.']);
    else
        disp(['High-pass filter of ',num2str(hp),' Hz will be applied.']);
    end

else
    hp = nan;
    disp(['Warning: Invalid High-pass filter value format. ',...
        'No filter will be applied.']);
end

%--------------------------------------------------------------------------
% Convert opts.lowpass to double
if isnumeric(opts.lowpass) && isscalar(opts.lowpass)
    lp = double(opts.lowpass);
    disp(['Low-pass filter of ',num2str(lp),' Hz will be applied.']);

elseif ischar(opts.lowpass)
    lp = str2double(opts.lowpass);

    if strcmpi(opts.lowpass,'none')
        disp('Warning: Low-pass filter will not be applied.');
    elseif isnan(lp)
        disp(['Warning: Invalid Low-pass filter value format. ',...
            'No filter will be applied.']);
    else
        disp(['Low-pass filter of ',num2str(lp),' Hz will be applied.']);
    end

else
    lp = nan;
    disp(['Warning: Invalid Low-pass filter value format. ',...
        'No filter will be applied.']);
end

%--------------------------------------------------------------------------
% Starts the status message
if isobject(hObject)
    set(handles.tools.connectome.text_wb,'String','Working...')
    pause(.1)
else
    disp('Working...');
end

if isempty(tspath) || isempty(outdir)
    he = errordlg('Please, select the time-series and outputh paths!');
    uiwait(he)
    return
end

%--------------------------------------------------------------------------
% Check if oudir exists, otherwise it creates outdir
if ~isfolder(outdir)
    mkdir(outdir)
end

%--------------------------------------------------------------------------
% load the source paths
if isfile(tspath)
    [~,~,ext] = fileparts(tspath);

    if strcmpi(ext,'.mat')
        tspath = {tspath};
    elseif strcmpi(ext,'.txt') || strcmpi(ext,'.csv') || strcmpi(ext,'.tsv')
        auxtspath = readcell(tspath,'Delimiter',[";","\t"]);
        if isnumeric(auxtspath{1})
            tspath = {tspath};
        else
            tspath = auxtspath;
        end
    else
        he = errordlg('Invalid file format!');
        uiwait(he)
        return
    end
else
    pathsep = strfind(tspath,';'); % find the file separators
    pathsep = [0,pathsep,length(tspath)+1]; % adds start and end positions

    auxtspath = cell(length(pathsep)-1,1);
    for ss = 1:length(pathsep)-1
        auxtspath{ss} = tspath(pathsep(ss)+1:pathsep(ss+1)-1); % convert paths string to cell array
    end
    tspath = auxtspath;
end

%--------------------------------------------------------------------------
% load the ROI names
if ~isempty(roinamespath)
    if ischar(roinamespath)
        if isfile(roinamespath)
            [~,~,ext] = fileparts(roinamespath);
            if strcmpi(ext,'.mat')
                auxroinames = load(roinamespath);
                roinamefields = fieldnames(auxroinames);
                auxroinames = auxroinames.(roinamefields{1});

            elseif strcmpi(ext,'.txt') || strcmpi(ext,'.csv') || strcmpi(ext,'.tsv')
                auxroinames = readcell(roinamespath,'Delimiter',[";",'\t']);
            else
                roinamespath = [];
            end
        else
            roinamespath = [];
        end

    elseif iscell(roinamespath)
        auxroinames = roinamespath;

    else
        roinamespath = [];
    end
end

for k = 1:length(tspath)

    %----------------------------------------------------------------------
    % loads time-series data
    [~,~,ext] = fileparts(tspath{k});

    if strcmpi(ext,'.mat')
        aux = load(tspath{k});
        tsfields = fieldnames(aux);
        tsdata = aux.(tsfields{1});
        if istable(tsdata)
            tscol = find(strcmp(tsdata.Properties.VariableNames,'timeseries'));
            if tscol
                tscell = tsdata.timeseries;
            else
                he = errordlg('The table does not have variable name timeseries');
                uiwait(he)
                return
            end

        elseif iscell(tsdata)
            tscell = tsdata(:,end);
        else
            tscell = {tsdata};
        end

    elseif strcmpi(ext,'.txt') || strcmpi(ext,'.csv') || strcmpi(ext,'.tsv')
        tscell = {readmatrix(tspath{k})};
    end

    %----------------------------------------------------------------------
    % calculates the connectomes
    tsfilt = cell(size(tscell));
    rconnec = nan([size(tscell{1},1),size(tscell{1},1),length(tscell)]);
    pconnec = nan([size(tscell{1},1),size(tscell{1},1),length(tscell)]);
    zconnec = nan([size(tscell{1},1),size(tscell{1},1),length(tscell)]);
    for s = 1:length(tscell)
        ts = tscell{s};
        ts = tsfilter(ts,hp,lp,tr);
        tsfilt{s} = ts;
        for i = 1:size(ts,1)-1
            for j = i+1:size(ts,1)
                [r,p] = corr(ts(i,:)',ts(j,:)','type','Pearson');
                rconnec(i,j,s) = r;
                pconnec(i,j,s) = p;
                zconnec(i,j,s) = atanh(r);
            end
        end
    end

    %----------------------------------------------------------------------
    % Generate ROI names
    if isempty(roinamespath)
        warning(['ROI names have an invalid file format! ',...
            'Generic names will be assigned to the ROIs.']);
        roinames = cell(size(tscell{1},1),1);
        for n = 1:length(roinames)
            roinames{n} = ['roi_',num2str(n)];
        end

    elseif size(auxroinames,2)==1
        roinames = auxroinames;

    else
        roinames = auxroinames(:,k);
        roinames(~cellfun(@ischar,roinames)) = [];
        if ~size(auxroinames,2)==length(tspath)
            warning(['The number of ROI names columns is different ',...
                'from the number of selected time-series files! ',...
                'Generic names will be assigned to the ROIs.']);
            roinames = cell(size(tscell{1},1),1);
            for n = 1:length(roinames)
                roinames{n} = ['roi_',num2str(n)];
            end
        end
    end

    %----------------------------------------------------------------------
    % Save filtered time seriess

    if length(tspath)==1
        tsfilename = 'tsfilt.mat';
    else
        tsfilename = sprintf('tsfilt%d.mat',k);
    end
    save(fullfile(outdir,tsfilename),'tsfilt');

    %----------------------------------------------------------------------
    % Save Pearson correlation coefficient connectome
    if opts.rsave
        if length(tspath)==1
            rfilename = 'rconnec.mat';
            rftfilename = 'rfeatmat.mat';
            rfeatmat = 'rfeatmat.csv';
            rftnames = 'rftnames.csv';
        else
            rfilename = sprintf('rconnec_ts%d.mat',k);
            rftfilename = sprintf('rfeatmat_ts%d.mat',k);
            rfeatmat = sprintf('rfeatmat_ts%d.csv',k);
            rftnames = sprintf('rftnames_ts%d.csv',k);
        end
        save(fullfile(outdir,rfilename),'rconnec','roinames');

        if opts.ftsave
            [ft,posft,ftnames] = connectome2featmatrix(rconnec,roinames);
            save(fullfile(outdir,rftfilename),'ft','posft','ftnames');
            writematrix(ft,fullfile(outdir,rfeatmat),'Delimiter','tab');
            writecell(ftnames,fullfile(outdir,rftnames),'Delimiter','tab');
        end
    end

    %----------------------------------------------------------------------
    % Save p-values connectome
    if opts.psave
        if length(tspath)==1
            pfilename = 'pconnec.mat';
            pftfilename = 'pfeatmat.mat';
            pfeatmat = 'pfeatmat.csv';
            pftnames = 'pftnames.csv';
        else
            pfilename = sprintf('pconnec_ts%d.mat',k);
            pftfilename = sprintf('pfeatmat_ts%d.mat',k);
            pfeatmat = sprintf('pfeatmat_ts%d.csv',k);
            pftnames = sprintf('pftnames_ts%d.csv',k);
        end
        save(fullfile(outdir,pfilename),'pconnec','roinames');

        if opts.ftsave
            [ft,posft,ftnames] = connectome2featmatrix(pconnec,roinames);
            save(fullfile(outdir,pftfilename),'ft','posft','ftnames');
            writematrix(ft,fullfile(outdir,pfeatmat),'Delimiter','tab');
            writecell(ftnames,fullfile(outdir,pftnames),'Delimiter','tab');
        end
    end

    %----------------------------------------------------------------------
    % Save Fisher Transformation connectome
    if opts.zsave
        if length(tspath)==1
            zfilename = 'zconnec.mat';
            zftfilename = 'zfeatmat.mat';
            zfeatmat = 'zfeatmat.csv';
            zftnames = 'zftnames.csv';
        else
            zfilename = sprintf('zconnec_ts%d.mat',k);
            zftfilename = sprintf('zfeatmat_ts%d.mat',k);
            zfeatmat = sprintf('zfeatmat_ts%d.csv',k);
            zftnames = sprintf('zftnames_ts%d.csv',k);
        end
        save(fullfile(outdir,zfilename),'zconnec','roinames');

        if opts.ftsave
            [ft,posft,ftnames] = connectome2featmatrix(zconnec,roinames);
            save(fullfile(outdir,zftfilename),'ft','posft','ftnames');
            writematrix(ft,fullfile(outdir,zfeatmat),'Delimiter','tab');
            writecell(ftnames,fullfile(outdir,zftnames),'Delimiter','tab');
        end
    end
end

%--------------------------------------------------------------------------
% Set status message as done
if isobject(hObject)
    set(handles.tools.connectome.text_wb,'String','Done!!!')
else
    disp('Done!!!');
end

%==========================================================================
% Auxiliar functions
function tsfilt = tsfilter(ts,hp,lp,tr)

fs = 1/tr;  % Sampling frequency in Hz
ts = ts';
if isnan(hp) && isnan(lp) % No filter is applied
    tsfilt = ts;

elseif isnan(lp) % high-pass filter
    % Normalize cutoff frequencies based on the Nyquist frequency
    Wn = hp/(fs/2);

    if Wn <= 0 || Wn >= 1
        error('Invalid highpass cutoff frequency relative to sampling rate.');
    end

    [b,a] = butter(1,Wn,'high');
    tsfilt = filtfilt(b,a,ts);  % Apply zero-phase high-pass filter

elseif isnan(hp) % low-pass filter
    % Normalize cutoff frequencies based on the Nyquist frequency
    Wn = lp/(fs/2);

    if Wn <= 0 || Wn >= 1
        error('Invalid lowpass cutoff frequency relative to sampling rate.');
    end

    [b, a] = butter(1, Wn, 'low');
    tsfilt = filtfilt(b, a, ts);  % Apply zero-phase low-pass filter

else % band-pass filter
    % Normalize cutoff frequencies based on the Nyquist frequency
    Wn = [hp lp]/(fs/2);

    % Validate bandpass range
    if Wn(1) >= Wn(2) || Wn(1) <= 0 || Wn(2) >= 1
        error(['Invalid bandpass range: check highpass and lowpass ',...
            'values relative to sampling rate.']);
    end

    % Design first-order Butterworth bandpass filter
    [b,a] = butter(1,Wn,'bandpass');

    % Apply zero-phase filtering (forward and reverse) to avoid phase distortion
    tsfilt = filtfilt(b,a,ts);
end

tsfilt = tsfilt';