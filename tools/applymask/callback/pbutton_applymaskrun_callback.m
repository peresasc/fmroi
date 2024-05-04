function pbutton_applymaskrun_callback(hObject, ~)
% pbutton_applymaskrun_callback is an internal function of fMROI.
%
% Syntax:
%   pbutton_applymaskrun_callback(hObject,~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2023, peres.asc@gmail.com
% Last update: Andre Peres, 22/08/2023, peres.asc@gmail.com

handles = guidata(hObject);

srcpath = get(handles.tools.applymask.edit_scrpath,'String');
maskpath = get(handles.tools.applymask.edit_maskpath,'String');
outdir = get(handles.tools.applymask.edit_outdir,'String');

%--------------------------------------------------------------------------
% loading the source paths
srcsep = strfind(srcpath,';'); % find the file separators
srcsep = [0,srcsep,length(srcpath)+1]; % adds start and end positions

auxsrcpath = cell(length(srcsep)-1,1);
for ss = 1:length(srcsep)-1
    auxsrcpath{ss} = srcpath(srcsep(ss)+1:srcsep(ss+1)-1); % covert paths string to cell array
end
srcpath = auxsrcpath;

%--------------------------------------------------------------------------
% loading the mask paths
masksep = strfind(maskpath,';');
masksep = [0,masksep,length(maskpath)+1]; % adds start and end positions

auxmaskpath = cell(length(masksep)-1,1);
for ms = 1:length(masksep)-1
    auxmaskpath{ms} = maskpath(masksep(ms)+1:masksep(ms+1)-1); % covert paths string to cell array
end
maskpath = auxmaskpath;

cellts = cell(length(srcpath),1);
cellstats = cell(length(srcpath),1);
maskidxall = [];
for s = 1:length(srcpath)
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

    srcvol = spm_vol(srcpath{s});
    srcdata = spm_data_read(srcvol);

    if s == 1
        maskvol = spm_vol(maskpath{s});
        mask = spm_data_read(maskvol);
    elseif length(maskpath) > 1
        maskvol = spm_vol(maskpath{s});
        mask = spm_data_read(maskvol);
    end

    maskidx = unique(mask);
    maskidx(maskidx==0) = [];
    maskidxall = [maskidxall;maskidx];
    
    sd = size(srcdata);
    sm = size(mask);
    if ~(isequal(sd,sm) || isequal(sd(1:3),sm))
        he = errordlg('The source image and mask have different sizes');
        uiwait(he)
        return
    end
    
    ts = zeros(length(maskidx),size(srcdata,4));
    stats = zeros(6,length(maskidx));
    stats(1,:) = maskidx;
    for mi = 1:length(maskidx) % Mask index loop
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
        % [~,fn,~] = fileparts(srcpath{s});
        % filename = sprintf([fn,'_maskid-%03d.nii'],maskidx(mi));
        % if size(imgmask,4) == 1 % check if the volume is 3D            
        %     srcvol.fname = fullfile(outdir,filename);
        %     v = spm_create_vol(srcvol);
        %     v.pinfo = [1;0;0]; % avoid SPM to rescale the masks
        %     v = spm_write_vol(v,imgmask);
        % else
        %     for k = 1:length(srcvol)
        %         srcvol(k).dat = squeeze(imgmask(:,:,:,k));
        %     end
        % 
        %     outpath = fullfile(outdir,filename);
        %     V4 = array4dtonii(srcvol,outpath,0,1);
        % end
        %------------------------------------------------------------------
        % Save masked images to nifti files
    end
    cellts{s} = ts;
    cellstats{s} = stats;
end

maskidx = unique(maskidxall);
maskmedian = nan(length(cellstats),length(maskidx));
maskmean = nan(length(cellstats),length(maskidx));
maskstd = nan(length(cellstats),length(maskidx));
maskmax = nan(length(cellstats),length(maskidx));
maskmin = nan(length(cellstats),length(maskidx));
for w = 1:length(cellstats)
    idx = find(ismember(maskidx,cellstats{w}(1,:)));
    maskmedian(w,idx) = cellstats{w}(2,:);
    maskmean(w,idx) = cellstats{w}(3,:);
    maskstd(w,idx) = cellstats{w}(4,:);
    maskmax(w,idx) = cellstats{w}(5,:);
    maskmin(w,idx) = cellstats{w}(6,:);
end

if length(maskpath)==1
    auxmaskpath = cell(size(srcpath));
    auxmaskpath(:) = maskpath;
    maskpath = auxmaskpath;
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