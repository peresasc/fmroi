function runconnectome(tspath,outdir,roinamespath,opts,hObject)
%
% Author: Andre Peres, 2024, peres.asc@gmail.com
% Last update: Andre Peres, 15/05/2024, peres.asc@gmail.com


if nargin < 2
    he = errordlg('Not enought input arguments!');
    uiwait(he)
    return
elseif nargin == 2
    roinamespath = [];
    opts.rsave = 1;
    opts.zsave = 1;
    opts.ftsave = 1;
    hObject = nan;
elseif nargin == 3
    opts.rsave = 1;
    opts.zsave = 1;
    opts.ftsave = 1;
    hObject = nan;
elseif nargin == 4
    hObject = nan;
else
    handles = guidata(hObject);
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

%--------------------------------------------------------------------------
% Starts the wait bar
if isobject(hObject)
    wb1 = get(handles.tools.connectome.wb1,'Position');
    wb2 = get(handles.tools.connectome.wb2,'Position');
    wb2(3) = 0;
    set(handles.tools.connectome.wb2,'Position',wb2)
else
    wb = waitbar(0,'Loading time-series...');
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
            tscell = tscell(:,end);
        end

    elseif strcmpi(ext,'.txt') || strcmpi(ext,'.csv') || strcmpi(ext,'.tsv')
        tscell = {readmatrix(tspath{k})};
    end

    %----------------------------------------------------------------------
    % calculates the connectomes
    rconnec = nan([size(tscell{1},1),size(tscell{1},1),length(tscell)]);
    pconnec = nan([size(tscell{1},1),size(tscell{1},1),length(tscell)]);
    zconnec = nan([size(tscell{1},1),size(tscell{1},1),length(tscell)]);
    for s = 1:length(tscell)
        ts = tscell{s};
        for i = 1:size(ts,1)-1
            for j = i+1:size(ts,1)
                [r,p] = corr(ts(i,:)',ts(j,:)','type','Pearson');
                rconnec(i,j,s) = r;
                pconnec(i,j,s) = p;
                zconnec(i,j,s) = atanh(r);
            end
        end
    end


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

    if length(tspath)==1
        zfilename = 'zconnec.mat';
        roinames_fn = 'roinames.mat';
    else
        zfilename = sprintf('zconnec_ts%d.mat',k);
        roinames_fn = sprintf('roinames_ts%d.mat',k);
    end

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
        save(fullfile(outdir,rfilename),'rconnec');

        if opts.ftsave
            [ft,posft,ftnames] = connectome2featmatrix(rconnec,roinames);
            save(fullfile(outdir,rftfilename),'ft','posft','ftnames');
            writematrix(ft,rfeatmat,'Delimiter','tab');
            writecell(ftnames,rftnames,'Delimiter','tab');
        end
    end
    
    % if opts.zsave
    %     save(fullfile(outdir,zfilename),'zconnec');
    %     if opt.ftsave
    %         [ft,posft,ftnames] = connectome2featmatrix(zconnec,roinames);
    %         save()
    %     end
    % end
    % save(fullfile(outdir,roinames_fn),'roinames');
    
end

