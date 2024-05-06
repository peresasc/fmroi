function runapplymask(hObject,srcpath,maskpath,outdir,opts)

handles = guidata(hObject);
if nargin < 4
    he = errordlg('Not enought input arguments!');
    uiwait(he)
    return
elseif nargin == 4
    opts.savenii = 1;
    opts.savestats = 1;
    opts.savets = 1;
end

if ~(isfield(opts,'savenii') && isfield(opts,'savestats')...
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
% loading the source paths
if isfile(srcpath)
    [~,~,ext] = fileparts(srcpath);

    if strcmpi(ext,'.nii') || strcmpi(ext,'.gz')
        srcpath = {srcpath};
    elseif strcmpi(ext,'.txt')
        auxsrcpath = readcell(srcpath,'Delimiter',';');
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
        maskpath = {maskpath};
    elseif strcmpi(ext,'.txt')
        auxmaskpath = readcell(maskpath,'Delimiter',';');
        maskpath = auxmaskpath;
    else
        he = errordlg('Invalid file format!');
        uiwait(he)
        return
    end

else
    masksep = strfind(maskpath,';');
    masksep = [0,masksep,length(maskpath)+1]; % adds start and end positions

    auxmaskpath = cell(length(masksep)-1,1);
    for ms = 1:length(masksep)-1
        auxmaskpath{ms} = maskpath(masksep(ms)+1:masksep(ms+1)-1); % covert paths string to cell array
    end
    maskpath = auxmaskpath;
end

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

%--------------------------------------------------------------------------
% Apply the masks in maskpath to source images in srcpath
cellts = cell(length(srcpath),1);
cellstats = cell(length(srcpath),1);
maskidxall = [];
wb1 = get(handles.tools.applymask.wb1,'Position');
wb2 = get(handles.tools.applymask.wb2,'Position');
for s = 1:length(srcpath)
    wb2(3) = wb1(3)*(s/length(srcpath)); % updates the waitbar
    set(handles.tools.applymask.wb2,'Position',wb2)
    pause(.1)
    srcvol = spm_vol(srcpath{s});
    srcdata = spm_data_read(srcvol);

    if s == 1 % avoid unecessary loading the mask in case it is the same for all source volumes
        maskvol = spm_vol(maskpath{s});
        mask = spm_data_read(maskvol);
    elseif length(maskpath) > 1
        maskvol = spm_vol(maskpath{s});
        mask = spm_data_read(maskvol);
    end

    maskidx = unique(mask); % mask indexes for the current source volume
    maskidx(maskidx==0) = [];
    maskidxall = [maskidxall;maskidx]; % mask indexes for all source volumes

    sd = size(srcdata);
    sm = size(mask);
    if ~(isequal(sd,sm) || isequal(sd(1:3),sm)) % check if the mask and srcvol have the same shape
        he = errordlg('The source image and mask have different sizes');
        uiwait(he)
        return
    end

    ts = zeros(length(maskidx),size(srcdata,4));
    stats = zeros(6,length(maskidx));
    stats(1,:) = maskidx;
    for mi = 1:length(maskidx) % Mask index loop
        set(handles.tools.applymask.text_wb,'String',sprintf('Source Image %d/%d - Maskidx %d/%d',s,length(srcpath),mi,length(maskidx)))
        curmask = mask==maskidx(mi);
        if ~isequal(sd,sm) % source image is 4D and mask 3D
            curmask = repmat(curmask,1,1,1,sd(4)); % transform the 3D mask to 4D
            imgmask = srcdata.*curmask;
        else
            imgmask = srcdata.*(curmask);
        end
        %------------------------------------------------------------------
        % Calculates the average time-series

        for t = 1:size(imgmask,4) % Using loop inteady identation is slower but allows for using different masks for each time point
            curimg = squeeze(imgmask(:,:,:,t));
            ts(mi,t) = mean(curimg(squeeze(curmask(:,:,:,t))));
        end


        %------------------------------------------------------------------
        % Calculates the stats
        stats(2,mi) = median(imgmask(curmask));
        stats(3,mi) = mean(imgmask(curmask));
        stats(4,mi) = std(imgmask(curmask));
        stats(5,mi) = max(imgmask(curmask));
        stats(6,mi) = min(imgmask(curmask));

        %------------------------------------------------------------------
        % Save masked images to nifti files
        if opts.savenii
            [~,fn,~] = fileparts(srcpath{s});
            filename = sprintf([fn,'_maskid-%03d.nii'],maskidx(mi));
            if size(imgmask,4) == 1 % check if the volume is 3D
                srcvol.fname = fullfile(outdir,filename);
                v = spm_create_vol(srcvol);
                v.pinfo = [1;0;0]; % avoid SPM to rescale the masks
                v = spm_write_vol(v,imgmask);
            else
                for k = 1:length(srcvol)
                    srcvol(k).dat = squeeze(imgmask(:,:,:,k));
                end

                outpath = fullfile(outdir,filename);
                V4 = array4dtonii(srcvol,outpath);
            end
        end
    end
    cellts{s} = ts;
    cellstats{s} = stats;
end

if length(maskpath)==1
    auxmaskpath = cell(size(srcpath));
    auxmaskpath(:) = maskpath;
    maskpath = auxmaskpath;
end

if opts.savets
    timeseries = [srcpath,maskpath,cellts];
    save(fullfile(outdir,'timeseries.mat'),'timeseries');

end

if opts.savestats
    maskidx = unique(maskidxall);
    maskmedian = nan(length(cellstats),length(maskidx));
    maskmean = nan(length(cellstats),length(maskidx));
    maskstd = nan(length(cellstats),length(maskidx));
    maskmax = nan(length(cellstats),length(maskidx));
    maskmin = nan(length(cellstats),length(maskidx));
    for w = 1:length(cellstats)
        idx = find(ismember(maskidx,cellstats{w}(1,:))); % find the current mask indexes among all indexes
        maskmedian(w,idx) = cellstats{w}(2,:);
        maskmean(w,idx) = cellstats{w}(3,:);
        maskstd(w,idx) = cellstats{w}(4,:);
        maskmax(w,idx) = cellstats{w}(5,:);
        maskmin(w,idx) = cellstats{w}(6,:);
    end

    mediancell = [srcpath,maskpath,num2cell(maskmedian)];
    meancell = [srcpath,maskpath,num2cell(maskmean)];
    stdcell = [srcpath,maskpath,num2cell(maskstd)];
    maxcell = [srcpath,maskpath,num2cell(maskmax)];
    mincell = [srcpath,maskpath,num2cell(maskmin)];

    varnames = cell(1,length(maskidx));
    for k = 1:length(maskidx)
        varnames{k} = sprintf('maskidx_%03d',maskidx(k));
    end
    varnames = [{'srcpath'},{'maskpath'},varnames];

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
disp('DONE!!!')