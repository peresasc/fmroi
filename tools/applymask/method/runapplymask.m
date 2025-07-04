function runapplymask(srcpath,maskpath,outdir,opts,hObject)
% runapplymask function applies one or more masks to a set of fMRI images
% defined in SRCPATH and computes summary statistics and/or time series 
% data for each mask. Optional preprocessing can also be applied to the
% time series data prior to extraction.
%
% Syntax:
% function runapplymask(srcpath,maskpath,outdir,opts,hObject)
%
% Inputs:
%    srcpath: String containg the paths to the source images separeted by
%             semicolons, or a path to a text file (.txt, .csv, or .tsv) 
%             containing the images paths in a line (separated by tabs or
%             semicolons) or in a column (1D array).
%
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
%
%     outdir: Path to the output directory (string).
%
%       opts: Structure with optional settings including preprocessing
%                   steps and output options. The following fields are
%                   supported:
%
%                            *** Saving data ***
%
%           opts.saveimg: (default: 0) Flag indicating if masked images 
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
%
%                            *** Cleaning data ***
%
%         opts.filter.tr: Repetition time (TR) in seconds. Used to compute 
%                         the sampling frequency for filtering.
%   opts.filter.highpass: High-pass cutoff frequency in Hz. Can be a 
%                         numeric value or the string 'none'. If numeric, 
%                         a Butterworth filter is applied.
%    opts.filter.lowpass: Low-pass cutoff frequency in Hz. Can be a 
%                         numeric value or the string 'none'. If numeric, 
%                         a Butterworth filter is applied.
%      opts.filter.order: (Optional, default = 1) Order of the Butterworth 
%                         filter. Applies to high-pass, low-pass, or 
%                         band-pass designs.
%
%       opts.regout.conf: Table, matrix, or cell array of confound files 
%                         (numeric or table) to be regressed out via 
%                         GLM. If multiple subjects are processed, must 
%                         be a cell array with one entry per subject.
%    opts.regout.selconf: Vector of column indices to select specific 
%                         confounds from `conf`. Can be empty to use 
%                         all columns.
%     opts.regout.demean: Logical flag (default: false) indicating whether 
%                         to include a constant (intercept) regressor 
%                         for mean removal during regression.
%
%       opts.smooth.fwhm: Full width at half maximum (FWHM) of the 
%                            spatial Gaussian kernel in mm (scalar).
%
%            opts.zscore: Logical flag. If true, the time series of each 
%                         voxel is z-scored (zero mean, unit std) after
%                         all other preprocessing steps.
%
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
% This function requires SPM12 to be installed.
%
% Author: Andre Peres, 2024, peres.asc@gmail.com
% Last update: Andre Peres, 28/05/2025, peres.asc@gmail.com


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

if isfield(opts,'regout') && isfield(opts.regout,'conf') &&...
        iscell(opts.regout.conf) && length(opts.regout.conf)~=length(srcpath)
    he = errordlg(['The number of confound files must match the number of BOLD images.', ...
                   newline, 'Check the field "opts.regout.conf".'], ...
                   'Mismatched Input');
    uiwait(he)
    return
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
    dwb = doublewaitbar([],0,'Loading images...',0,[]);    
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
            voxelsize = sqrt(sum(srcvol(1).mat(1:3, 1:3).^2));
            srcdata = spm_data_read(srcvol);            
        else
            srcdata = spm_vol(srcpath{s});
            voxelsize = sqrt(sum(srcdata(1).mat(1:3, 1:3).^2));
            srcdata = spm_data_read(srcdata);
        end
        
        if s == 1 % avoid unnecessary loading of the mask in case it is the same for all source volumes
            maskvol = spm_vol(maskpath{s});
            mask = uint16(spm_data_read(maskvol));
        elseif length(maskpath) > 1
            maskvol = spm_vol(maskpath{s});
            mask = uint16(spm_data_read(maskvol));
        end

        masknd = ndims(mask);  % get the number of dimensions of the mask
        if masknd ~= 3  % check if the mask does not have exactly 3 dimensions
            msg = sprintf(['The mask ',maskpath{s},...
                ' must have 3 dimensions.\n', ...
                'The mask has %d dimensions.'], ...
                masknd);
            he = errordlg(msg,'Invalid Mask Dimensions');
            uiwait(he)
            return
        end

        maskidx = unique(mask); % mask indexes for the current source volume
        maskidx(maskidx==0) = [];

        if isempty(maskidx) % check if the mask is empty
            he = errordlg(['The mask ',maskpath{s},...
                ' has no indices different from zero.',...
                ' Check if the indices are positive integers']);
            uiwait(he)
            return
        end
        
        sd = size(srcdata);
        sm = size(mask);
        srcdata2d = reshape(srcdata,[],sd(4));  % reshape to (x*y*z,t)
        if ~isequal(sd(1:3),sm) % check if the mask and srcdata have the same shape
            msg = sprintf(['The source image and the mask do not match',...
                ' in spatial dimensions!\n', ...
                'Source image dimensions: [%d %d %d]\n', ...
                'Mask dimensions: [%d %d %d]'], ...
                sd(1), sd(2), sd(3), sm(1), sm(2), sm(3));
            he = errordlg(msg, 'Dimension Mismatch');
            uiwait(he)
            return
        end

        ts = zeros(length(maskidx),sd(4));
        ts2 = zeros(length(maskidx),sd(4));
        stats = zeros(6,length(maskidx));
        stats(1,:) = maskidx;
        auxmaskidxall = cell(length(maskidx),1);

        for mi = 1:length(maskidx) % Mask index loop
            
            if isobject(hObject)
                msg = sprintf('Source Image %d/%d - Mask %d/%d - idx %d/%d',...
                    s,length(srcpath),m,size(masktypespath,2),mi,length(maskidx));
                set(handles.tools.applymask.text_wb,'String',msg)
            else
                msg1 = sprintf('Source Image %d/%d - Mask %d/%d',...
                    s,length(srcpath),m,size(masktypespath,2));
                p1 = (length(srcpath)*(m-1)+s)/...
                    (length(srcpath)*size(masktypespath,2));

                msg2 = sprintf('Mask index %d/%d',mi,length(maskidx));
                p2 = mi/length(maskidx);
                
                dwb = doublewaitbar(dwb,p1,msg1,p2,msg2);                
            end
            pause(.1)
            auxmaskidxall{mi} = sprintf('mask-%03d_idx-%03d',m,maskidx(mi));
            curmask = mask==maskidx(mi);
            
            %--------------------------------------------------------------
            % If smoothing is requested, dilate the current mask to ensure that
            % the smoothing kernel does not include zeros outside the ROI boundary.
            % Smoothing (e.g., Gaussian) involves neighboring voxels within a certain
            % spatial radius (typically 3×σ). If the ROI mask is too tight, smoothing
            % near the mask edges may include background zeros, introducing edge artifacts.
            if isfield(opts,'smooth') && ~isempty(opts.smooth)

                orig_curmask = curmask;

                sigma_mm = opts.smooth.fwhm/(2*sqrt(2*log(2))); % calculates sigma using fwhm
                sigma_vox = sigma_mm./voxelsize; % convert sigma from mm to voxels                
                r = ceil(3 * max(sigma_vox)); % defines radius as 3 sigmas

                se = strel('sphere', r);
                curmask = imdilate(curmask, se);  % expanded ROI for smoothing support
            end
            %------------------------------------------------------------------
            
            % apply mask in the time series (2D array)
            mask1d = curmask(:);
            auxts = srcdata2d(logical(mask1d),:); % Apply the mask in srcdata

            %==============================================================
            % CLEANING DATA
            if isfield(opts,'regout') && ~isempty(opts.regout)
                if iscell(opts.regout.conf)
                    auxts = preproc_regout(auxts,opts.regout.conf{s},...
                        opts.regout.selconf,opts.regout.demean);
                else
                    auxts = preproc_regout(auxts,opts.regout.conf,...
                        opts.regout.selconf,opts.regout.demean);
                end
            end

            if isfield(opts,'filter') && ~isempty(opts.filter)
                auxts = preproc_butter(auxts,opts.filter.highpass,...
                    opts.filter.lowpass,opts.filter.tr,opts.filter.order);
            end

            if isfield(opts,'smooth') && ~isempty(opts.smooth)

                % Preallocate output volume
                imgmask4d = zeros(size(srcdata2d));
                imgmask4d(logical(mask1d),:) = auxts;
                imgmask4d = reshape(imgmask4d,sd);

                % Apply the same Gaussian filter to each time volume
                for t = 1:size(imgmask4d,4)
                    imgmask4d(:,:,:,t) = imgaussfilt3(imgmask4d(:,:,:,t),...
                        sigma_vox,'FilterDomain','auto','Padding','replicate');
                end

                imgmask2d = reshape(imgmask4d,[],sd(4));

                % transform auxts back to the original mask shape
                curmask = orig_curmask;
                mask1d = curmask(:);
                auxts = imgmask2d(logical(mask1d),:); % Apply the mask in srcdata
            end

            if isfield(opts,'zscore') && opts.zscore
                auxts = zscore(auxts');
                auxts = auxts';
            end            
            %==============================================================
            
            ts(mi,:) = mean(auxts);

            %------------------------------------------------------------------
            % Calculates the stats
            stats(2,mi) = median(auxts(:));
            stats(3,mi) = mean(auxts(:));
            stats(4,mi) = std(auxts(:));
            stats(5,mi) = max(auxts(:));
            stats(6,mi) = min(auxts(:));

            %------------------------------------------------------------------
            % Save masked images to nifti files
            if opts.saveimg
                imgmask4d = zeros(size(srcdata2d));
                imgmask4d(logical(mask1d),:) = auxts;
                imgmask4d = reshape(imgmask4d,sd);

                [~,fn,~] = fileparts(srcpath{s});
                [~,fn,~] = fileparts(fn);
                filename = sprintf([fn,'_mask-%03d_idx-%03d.nii'],...
                                    m,maskidx(mi));
                if size(imgmask4d,4) == 1 % check if the volume is 3D
                    srcvol.fname = fullfile(outdir,filename);
                    v = spm_create_vol(srcvol);
                    v.pinfo = [1;0;0]; % avoid SPM to rescale the masks
                    spm_write_vol(v,imgmask4d);
                else
                    for k = 1:length(srcvol)
                        srcvol(k).dat = squeeze(imgmask4d(:,:,:,k));
                    end
                    clear imgmask4d
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
                (length(srcpath)*size(masktypespath,2)));
            set(handles.tools.applymask.wb2,'Position',wb2)
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
    dwb = doublewaitbar(dwb,[],'DONE!!!',[],'');
end

disp('DONE!!!')