function [ft, posft, names] = connectome2featmatrix(fcinput)

if ~iscell(fcinput)
    fcinput = {fcinput};
end

ft = [];
for s = 1:length(fcinput)
    curinput = fcinput{s};

    if ischar(curinput)
        [~,~,ext] = fileparts(curinput);

        if strcmpi(ext,'.mat')
            auxconn = load(fcinput{s});
            connfields = fieldnames(auxconn);
            connec = auxconn.(connfields{1});
        elseif strcmpi(ext,'.txt') || strcmpi(ext,'.csv') || strcmpi(ext,'.tsv') % otherwise the path must point to a square matrix
            connec = readmatrix(curinput,'Delimiter',[";","\t"]);
        end

    else
        connec = curinput;
    end

    for k = 1:size(connec,3)
        curconn = squeeze(connec(:,:,k));
        ft = [ft; curconn(triu(true(size(curconn)),1))'];
    end
end

names = cell(size(connec,1),1);
for n = 1:length(names)
    names{n} = ['roi_',num2str(n)];
end

% posft variable maps the ft vectors back to the original space featxfeat
posft = nan(size(curconn));
count = 0;
for j = 1:size(curconn,2)
    for i = 1:size(curconn,1)
        if i<j
            count = count+1;
            posft(i,j) = count;
        end
    end
end