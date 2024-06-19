function [ft,posft,ftnames] = connectome2featmatrix(fcinput,roinamespath)
% CONNECTOME2FEATMATRIX Convert connectome data to feature matrix format.
%
% This function processes input functional connectivity (FC) data to 
% generate feature matrices. Optionally, it includes ROI names in the 
% output feature names.
%
% Syntax:
%  function [ft,posft,ftnames] =...
%                  connectome2featmatrix(fcinput,roinamespath)
%
% Inputs:
%         fcinput: Functional connectivity correlation matrix (connectome).
%                  Can be a single numeric array, a cell array of matrices,
%                  or a file path. If the input is a cell array, 
%                  connectome2featmatrix will treat each data within the 
%                  cells as a new sample, resulting in as many connectomes
%                  as the number of cells. The supported file formats are 
%                  .mat, .txt, .csv, and .tsv.
%    roinamespath: (Optional) Path to the file containing ROI names.
%                  Supported formats are .mat, .txt, .csv, and .tsv.
%                  The file must have the same length as the number of
%                  connectome lines/columns (it is a square matrix).
%                  Each ROI name in roinamespath corresponds to the ROI 
%                  from which each time-series was extracted. If not 
%                  provided, generic names will be assigned.
%
% Outputs:
%              ft: Feature matrix with each row representing a vectorized 
%                  upper triangle of the input connectomes.
%           posft: Position mapping of the feature vectors back to the 
%                  original matrix space.
%         ftnames: Cell array containing names for each feature based on 
%                  the ROI names.
%
% Examples:
%  [ft, posft, ftnames] = connectome2featmatrix('connectome.mat')
%  [ft, posft, ftnames] = connectome2featmatrix({'connectome1.mat',...
%                         'connectome2.mat'},'roinames.txt')
%
% Author: Andre Peres, 2024, peres.asc@gmail.com
% Last update: Andre Peres, 19/06/2024, peres.asc@gmail.com

if nargin < 2
    roinamespath = [];
end

if ~iscell(fcinput)
    fcinput = {fcinput};
end

%--------------------------------------------------------------------------
% load the ROI names
if ~isempty(roinamespath)
    if ischar(roinamespath)
        if isfile(roinamespath)
            [~,~,ext] = fileparts(roinamespath);
            if strcmpi(ext,'.mat')
                roinames = load(roinamespath);
                roinamefields = fieldnames(roinames);
                roinames = roinames.(roinamefields{1});

            elseif strcmpi(ext,'.txt') ||...
                   strcmpi(ext,'.csv') ||...
                   strcmpi(ext,'.tsv')
                roinames = readcell(roinamespath,'Delimiter',[";",'\t']);                
            else
                roinamespath = [];
            end
        else
            roinamespath = [];
        end

    elseif iscell(roinamespath)
        roinames = roinamespath;

    else
        roinamespath = [];
    end
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
        elseif strcmpi(ext,'.txt') ||...
               strcmpi(ext,'.csv') ||...
               strcmpi(ext,'.tsv') % otherwise the path must point to a square matrix
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

if isempty(roinamespath)
    roinames = cell(size(connec,1),1);
    for n = 1:length(roinames)
        roinames{n} = ['roi_',num2str(n)];
    end
end

% posft variable maps the ft vectors back to the original space featxfeat
ftnames = cell(size(ft,2),1);
posft = nan(size(curconn));
count = 0;
for j = 1:size(curconn,2)
    for i = 1:size(curconn,1)
        if i<j
            count = count+1;
            posft(i,j) = count;
            ftnames{count} = [roinames{i},'_x_',roinames{j}];
        end
    end
end