function runconnectome(tspath,outdir,opts,hObject)
%
% Author: Andre Peres, 2024, peres.asc@gmail.com
% Last update: Andre Peres, 15/05/2024, peres.asc@gmail.com


if nargin < 2
    he = errordlg('Not enought input arguments!');
    uiwait(he)
    return
elseif nargin == 2
    opts.saveimg = 1;
    opts.savestats = 1;
    opts.savets = 1;
    opts.groupts = 0;
    hObject = nan;
elseif nargin == 3
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
% loading the source paths
if isfile(tspath)
    [~,~,ext] = fileparts(tspath);

    if strcmpi(ext,'.mat')
        tspath = {tspath};
    elseif strcmpi(ext,'.txt')
        auxtspath = readcell(tspath,'Delimiter',[";",'\t']);
        tspath = auxtspath;
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
% Starts the wait bar
if isobject(hObject)
    wb1 = get(handles.tools.connectome.wb1,'Position');
    wb2 = get(handles.tools.connectome.wb2,'Position');
    wb2(3) = 0;
    set(handles.tools.connectome.wb2,'Position',wb2)
else
    wb = waitbar(0,'Loading time-series...');
end


for i = 1:length(tspath)
    aux = load(tspath{i});
    tsfields = fieldnames(aux);
    tsdata = aux.(tsfields{1});
    if istable(tsdata)
        tscol = find(strcmp(tsdata.Properties.VariableNames,'timeseries'));
        if tscol
            ts = tsdata.timeseries;
        else
            he = errordlg('The table does not have variable name timeseries');
            uiwait(he)
            return
        end

    elseif iscell(tsdata)
        ts = ts(:,end);
    end
    
    for s = 1
    end

end