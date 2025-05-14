function runapplymask(srcpath,maskpath,outdir,opts,hObject)
% runapplymask function applies masks to a set of source images and saves
% the results as time series and statistics.
%
% Syntax:
% function runapplymask(srcpath,maskpath,outdir,opts,hObject)
%
% Inputs:
%    srcpath: String containg the paths to the source images separeted by
%             semicolons, or a path to a text file (.txt, .csv, or .tsv) 
%             containing the images paths in a line (separated by tabs or
%             semicolons) or in a column (1D array).
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
%     outdir: Path to the output directory (string).
%       opts: (optional) A structure containing options for saving outputs.
%           opts.saveimg: (default: 1) Flag indicating if masked images 
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
% This function requires SPM to be installed.
%
% Author: Andre Peres, 2024, peres.asc@gmail.com
% Last update: Andre Peres, 06/05/2024, peres.asc@gmail.com


if nargin < 3
    he = errordlg('Not enought input arguments!');
    uiwait(he)
    return
elseif nargin == 3
    opts.saveimg = 1;
    opts.savestats = 1;
    opts.savets = 1;
    opts.groupts = 0;
    hObject = nan;
elseif nargin == 4
    hObject = nan;
else
    handles = guidata(hObject);
end

if ~(isfield(opts,'saveimg') && isfield(opts,'savestats')...
        && isfield(opts,'savets'))
    he = errordlg('opts input argument was not set properly!');
    uiwait(he)
    return
end

if isempty(srcpath) || isempty(maskpath)
    he = errordlg('Please, select the source images and masks paths!');
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
if isfile(srcpath)
    [~,~,ext] = fileparts(srcpath);

    if strcmpi(ext,'.nii') || strcmpi(ext,'.gz')
        srcpath = {srcpath};
    elseif strcmpi(ext,'.txt') || strcmpi(ext,'.csv') || strcmpi(ext,'.tsv')
        auxsrcpath = readcell(srcpath,'Delimiter',[";",'\t']);
        srcpath = auxsrcpath;
    else
        he = errordlg('Invalid file format!');
        uiwait(he)
        return
    end
else
    srcsep = strfind(srcpath,';'); % find the file separators
    srcsep = [0,srcsep,length(srcpath)+1]; % adds start and end positions

    auxsrcpath = cell(length(srcsep)-1,1);
    for ss = 1:length(srcsep)-1
        auxsrcpath{ss} = srcpath(srcsep(ss)+1:srcsep(ss+1)-1); % covert paths string to cell array
    end
    srcpath = auxsrcpath;
end

%--------------------------------------------------------------------------
% loading the mask paths

if isfile(maskpath)
    [~,~,ext] = fileparts(maskpath);

    if strcmpi(ext,'.nii') || strcmpi(ext,'.gz')
        masktypespath = {maskpath};
    elseif strcmpi(ext,'.txt') || strcmpi(ext,'.csv') || strcmpi(ext,'.tsv')
        masktypespath = readcell(maskpath,'Delimiter',[";",'\t']);
    else
        he = errordlg('Invalid file format!');
        uiwait(he)
        return
    end

else
    masksep = strfind(maskpath,';');
    masksep = [0,masksep,length(maskpath)+1]; % adds start and end positions

    masktypespath = cell(length(masksep)-1,1);
    for ms = 1:length(masksep)-1
        masktypespath{ms} = maskpath(masksep(ms)+1:masksep(ms+1)-1); % covert paths string to cell array
    end

end

%--------------------------------------------------------------------------
% Starts the wait bar
if isobject(hObject)
    wb1 = get(handles.tools.applymask.wb1,'Position');
    wb2 = get(handles.tools.applymask.wb2,'Position');
    wb2(3) = 0;
    set(handles.tools.applymask.wb2,'Position',wb2)
else
    wb = waitbar(0,'Loading images...');
end

cellts = cell(length(srcpath),size(masktypespath,2));
cellstats = cell(length(srcpath),size(masktypespath,2));
allmaskidx = cell(length(srcpath),size(masktypespath,2));
allmaskpath = cell(length(srcpath),size(masktypespath,2));
allsrcpath = cell(length(srcpath),size(masktypespath,2));
for m = 1:size(masktypespath,2) % iterates over the different mask types
    clear maskpath
    maskpath = masktypespath(:,m);
    maskpath(~cellfun(@ischar,maskpath)) = [];
    maskpath(~isfile(maskpath)) = [];

    %--------------------------------------------------------------------------
    % check if the number of masks are the same as source volumes.
    if ~(length(maskpath)==1 || length(maskpath)==length(srcpath))
        nmf = length(maskpath);
        nsf = length(srcpath);
        he = errordlg([...
            'The number of mask files should be one or the same number',...
            'as the source images. You have selected ',...
            sprintf('%d mask files and %d source images!',nmf,nsf)]);
        uiwait(he)
        return
    end


    for s = 1:length(srcpath)        

        if opts.saveimg % Avoid unnecessary loading of the SPM vol structure to save RAM
            srcvol = spm_vol(srcpath{s});
            srcdata = spm_data_read(srcvol);
        else
            srcdata = spm_vol(srcpath{s});
            srcdata = spm_data_read(srcdata);
        end
        
        if s == 1 % avoid unnecessary loading of the mask in case it is the same for all source volumes
            maskvol = spm_vol(maskpath{s});
            mask = uint16(spm_data_read(maskvol));
        elseif length(maskpath) > 1
            maskvol = spm_vol(maskpath{s});
            mask = uint16(spm_data_read(maskvol));
        end

        maskidx = unique(mask); % mask indexes for the current source volume
        maskidx(maskidx==0) = [];


        if isempty(maskidx) % check if the mask is empty
            he = errordlg(['The mask ',maskpath{s},' has no indices different from zero. Check if the indices are positive integers']);
            uiwait(he)
            return
        end

        sd = size(srcdata);
        sm = size(mask);
        if ~(isequal(sd,sm) || isequal(sd(1:3),sm)) % check if the mask and srcdata have the same shape
            he = errordlg('The source image and mask have different sizes');
            uiwait(he)
            return
        end

        ts = zeros(length(maskidx),size(srcdata,4));
        stats = zeros(6,length(maskidx));
        stats(1,:) = maskidx;
        auxmaskidxall = cell(length(maskidx),1);
        for mi = 1:length(maskidx) % Mask index loop
            msg = sprintf('Source Image %d/%d - Mask %d/%d - idx %d/%d',...
                s,length(srcpath),m,size(masktypespath,2),mi,length(maskidx));
            if isobject(hObject)
                set(handles.tools.applymask.text_wb,...
                    'String',msg)
            else
                waitbar((length(srcpath)*(m-1)+s-1)/...
                (length(srcpath)*size(masktypespath,2)),wb,msg);
            end
            pause(.1)
            auxmaskidxall{mi} = sprintf('mask-%03d_idx-%03d',m,maskidx(mi));
            curmask = mask==maskidx(mi);
            
            datamask = cell(sd(4),1);
            for t = 1:sd(4)
                curdata = squeeze(srcdata(:,:,:,t));
                if ~isequal(sd,sm)                    
                    datamask{t} = curdata(curmask)';
                else
                    datamask{t} = curdata(squeeze(curmask(:,:,:,t)))';
                end
            end


            %------------------------------------------------------------------
            % Calculates the average time-series
            vecdatamask = [];
            for t = 1:length(datamask) % Using loop instead identation is slower but allows for using different masks for each time point
                ts(mi,t) = mean(datamask{t});
                vecdatamask = [vecdatamask,datamask{t}];
            end


            %------------------------------------------------------------------
            % Calculates the stats
            stats(2,mi) = median(vecdatamask);
            stats(3,mi) = mean(vecdatamask);
            stats(4,mi) = std(vecdatamask);
            stats(5,mi) = max(vecdatamask);
            stats(6,mi) = min(vecdatamask);

            %------------------------------------------------------------------
            % Save masked images to nifti files
            if opts.saveimg
                if ~isequal(sd,sm) % source image is 4D and mask 3D
                    curmask4d = repmat(curmask,1,1,1,sd(4)); % transform the 3D mask to 4D                    
                else
                    curmask4d = curmask;
                end

                imgmask = zeros(size(srcdata));
                imgmask(curmask4d) = vecdatamask;
                [~,fn,~] = fileparts(srcpath{s});
                filename = sprintf([fn,'_mask-%03d_idx-%03d.nii'],m,maskidx(mi));
                if size(imgmask,4) == 1 % check if the volume is 3D
                    srcvol.fname = fullfile(outdir,filename);
                    v = spm_create_vol(srcvol);
                    v.pinfo = [1;0;0]; % avoid SPM to rescale the masks
                    spm_write_vol(v,imgmask);
                else
                    for k = 1:length(srcvol)
                        srcvol(k).dat = squeeze(imgmask(:,:,:,k));
                    end
                    clear imgmask
                    outpath = fullfile(outdir,filename);
                    array4dtonii(srcvol,outpath);
                end                
            end
        end
        %------------------------------------------------------------------
        % updates cell arrays
        allmaskidx{s,m} = auxmaskidxall;
        cellts{s,m} = ts;
        cellstats{s,m} = stats;

        %------------------------------------------------------------------
        % updates waitbar
        if isobject(hObject)
            wb2(3) = wb1(3)*((length(srcpath)*(m-1)+s)/...
                (length(srcpath)*size(masktypespath,2))); % updates the waitbar
            set(handles.tools.applymask.wb2,'Position',wb2)
        else
            waitbar((length(srcpath)*(m-1)+s)/...
                (length(srcpath)*size(masktypespath,2)),wb,msg);
        end
        pause(.1)
    end

    allmaskpath(:,m) = maskpath;
    allsrcpath(:,m) = srcpath;
end

%--------------------------------------------------------------------------
% Save time-series
if opts.savets
    if opts.groupts
        usrcpath = unique(allsrcpath(:));
        timeseries = cell(length(usrcpath),4);
        for i = 1:length(usrcpath)
            srcts = cellts(strcmp(allsrcpath,usrcpath{i}));
            idx = allmaskidx(strcmp(allsrcpath,usrcpath{i}));
            timeseries{i,1} = usrcpath{i};
            timeseries{i,2} = allmaskpath(strcmp(allsrcpath,usrcpath{i}));
            timeseries{i,3} = cat(1,idx{:});
            timeseries{i,4} = cat(1,srcts{:});

            tsname = [allsrcpath(strcmp(allsrcpath,usrcpath{i})),timeseries{i,2}];
            tsnametab = cell2table(tsname,"VariableNames",...
            {'srcpath','maskpath'});
            writetable(tsnametab,fullfile(outdir,['tsfilename',sprintf('_img-%03d',i),'.csv']),'Delimiter','tab');
            writematrix(timeseries{i,4},fullfile(outdir,['timeseries',sprintf('_img-%03d',i),'.csv']),'Delimiter','tab');
        end
        tstab = cell2table(timeseries,"VariableNames",...
            {'srcpath','maskpath','maskidx','timeseries'});
        save(fullfile(outdir,'timeseriestab.mat'),'tstab');
        
    else
        for j = 1:size(cellts,2)
            timeseries = [allsrcpath(:,j),allmaskpath(:,j),allmaskidx(:,j),cellts(:,j)];
            tstab = cell2table(timeseries,"VariableNames",...
                {'srcpath','maskpath','maskidx','timeseries'});
            save(fullfile(outdir,['timeseriestab',sprintf('_mask-%03d',j),'.mat']),'tstab');
            for i = 1:size(cellts,1)
                writetable(tstab(i,1:2),fullfile(outdir,['tsfilename',sprintf('_img-%03d_mask-%03d',i,j),'.csv']),'Delimiter','tab');
                writematrix(cellts{i,j},fullfile(outdir,['timeseries',sprintf('_img-%03d_mask-%03d',i,j),'.csv']),'Delimiter','tab');
            end
        end
    end    
end

%--------------------------------------------------------------------------
% Save ROI stats
if opts.savestats
    c1 = [allmaskidx(:)];
    c2 = cat(1,c1{:});

    maskidx = unique(c2);
    maskmedian = nan(size(cellstats,1),length(maskidx));
    maskmean = nan(size(cellstats,1),length(maskidx));
    maskstd = nan(size(cellstats,1),length(maskidx));
    maskmax = nan(size(cellstats,1),length(maskidx));
    maskmin = nan(size(cellstats,1),length(maskidx));
    for i = 1:size(cellstats,1)
        for j = 1:size(cellstats,2)
            for k = 1:length(allmaskidx{i,j})
                idx = find(strcmp(maskidx,allmaskidx{i,j}{k})); % find the current mask indexes among all indexes
                maskmedian(i,idx) = cellstats{i,j}(2,k);
                maskmean(i,idx) = cellstats{i}(3,k);
                maskstd(i,idx) = cellstats{i}(4,k);
                maskmax(i,idx) = cellstats{i}(5,k);
                maskmin(i,idx) = cellstats{i}(6,k);
            end
        end
    end

    mediancell = [srcpath,num2cell(maskmedian)];
    meancell = [srcpath,num2cell(maskmean)];
    stdcell = [srcpath,num2cell(maskstd)];
    maxcell = [srcpath,num2cell(maskmax)];
    mincell = [srcpath,num2cell(maskmin)];

    varnames = [{'srcpath'},maskidx'];

    mediantable = cell2table(mediancell,"VariableNames",varnames);
    meantable = cell2table(meancell,"VariableNames",varnames);
    stdtable = cell2table(stdcell,"VariableNames",varnames);
    maxtable = cell2table(maxcell,"VariableNames",varnames);
    mintable = cell2table(mincell,"VariableNames",varnames);

    writetable(mediantable,fullfile(outdir,'median.csv'),'Delimiter','tab');
    writetable(meantable,fullfile(outdir,'mean.csv'),'Delimiter','tab');
    writetable(stdtable,fullfile(outdir,'std.csv'),'Delimiter','tab');
    writetable(maxtable,fullfile(outdir,'max.csv'),'Delimiter','tab');
    writetable(mintable,fullfile(outdir,'min.csv'),'Delimiter','tab');
end

%--------------------------------------------------------------------------
% Update waitbar
if isobject(hObject)
    set(handles.tools.applymask.text_wb,...
        'String','DONE!!!')
else
    waitbar(1,wb,'DONE!!!');
end

disp('DONE!!!')