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
for i = 1:length(srcsep)-1
    auxsrcpath{i} = srcpath(srcsep(i)+1:srcsep(i+1)-1); % covert paths string to cell array
end
srcpath = auxsrcpath;

%--------------------------------------------------------------------------
% loading the mask paths
masksep = strfind(maskpath,';');
masksep = [0,masksep,length(maskpath)+1]; % adds start and end positions

auxmaskpath = cell(length(masksep)-1,1);
for i = 1:length(masksep)-1
    auxmaskpath{i} = maskpath(masksep(i)+1:masksep(i+1)-1); % covert paths string to cell array
end
maskpath = auxmaskpath;

for i = 1:length(srcpath)
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

    srcvol = spm_vol(srcpath{i});
    srcdata = spm_data_read(srcvol);

    if i == 1
        maskvol = spm_vol(maskpath{i});
        mask = spm_data_read(maskvol);
    elseif length(maskpath) > 1
        maskvol = spm_vol(maskpath{i});
        mask = spm_data_read(maskvol);
    end

    maskidx = unique(mask);
    maskidx(maskidx==0) = [];
    
    sd = size(srcdata);
    sm = size(mask);
    if ~(isequal(sd,sm) || isequal(sd(1:3),sm))
        he = errordlg('The source image and mask have different sizes');
        uiwait(he)
        return
    end

    if ~isequal(sd,sm) % source image is 4D and mask 3D
        mask4d = repmat(mask,1,1,1,sd(4));
        imgmask = srcdata.*mask4d;
    else
        imgmask = srcdata.*mask;
    end

    [~,fn,~] = fileparts(srcpath{i});
    if size(imgmask,4) == 1 % check if the volume is 3D
        srcvol.fname = fullfile(outdir,[fn,'_masked.nii']);
        v = spm_create_vol(srcvol);
        v.pinfo = [1;0;0]; % avoid SPM to rescale the masks
        v = spm_write_vol(v,imgmask);
    else
        for k = 1:length(srcvol)
            srcvol(k).dat = squeeze(imgmask(:,:,:,k));
        end

        outpath = fullfile(outdir,[fn,'_masked.nii']);
        V4 = array4dtonii(srcvol,outpath,0,1);
    end
end





