function pbutton_roisave_callback(hObject, ~)
% pbutton_roisave_callback is an internal function of fMROI.
%
% Syntax:
%   pbutton_roisave_callback(hObject, ~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

global st
handles = guidata(hObject);

if ~get(handles.checkbox_roisaveatlas,'Value') &&...
        ~get(handles.checkbox_roisavebinmasks,'Value')
    set(handles.checkbox_roisaveatlas,'Value',1);
end

%--------------------------------------------------------------------------
% Select the path to save the files
srcfilename = fullfile(handles.tmpdir,'roi_under-construction.nii');

[fn, pn, idx] = uiputfile('*.nii');
if idx == 0
    return
end
outfilename = fullfile(pn,fn);
[pn,fn,ext] = fileparts(outfilename);

%--------------------------------------------------------------------------
% Generate a table with the ROI center and N of voxels, and save in the
% outfilename_info.txt
datalut = get(handles.table_roilut,'Data');
nvox = zeros(length(st.roimasks),1);
center = zeros(length(st.roimasks),3);
for i = 1:length(st.roimasks)
    binmask = uint16(logical(st.roimasks{i}));
    [x,y,z] = find3d(binmask);
    nvox(i) = length(x);
    cpima = round(mean([x,y,z]))';
    cpscan = st.vols{1}.mat*[cpima;1];
    center(i,:) = cpscan(1:3);
end

infoname = [pn,filesep,fn,'_info.txt'];
infotable = table(cellfun(@uint16,datalut(:,1)),datalut(:,2),...
    nvox,center(:,1),center(:,2),center(:,3),...
    'VariableNames',{'Index','ROI_Names','N_voxels','Center_X','Center_Y','Center_Z'});

writetable(infotable,infoname,...
        'WriteRowNames',true,'Delimiter','tab');

%--------------------------------------------------------------------------
% Save each ROI as a independent mask
if get(handles.checkbox_roisavebinmasks,'Value')   
    for i = 1:length(st.roimasks)
        binmask = uint16(logical(st.roimasks{i}));
        
        curroutfn = [pn,filesep,fn,'_',datalut{i,2},ext];
        
        vsrc = spm_vol(srcfilename);
        vsrc.fname = curroutfn;
        V = spm_create_vol(vsrc);
        V.pinfo = [1;0;0]; % avoid SPM to rescale the masks
        V = spm_write_vol(V, binmask);        
    end    
end

%--------------------------------------------------------------------------
% Save the ROIs as a Atlas + Color LUT
if get(handles.checkbox_roisaveatlas,'Value')
    % Move roi_under-construction.nii to selected path
    s = movefile(srcfilename,outfilename);
    if ~s
        he = errordlg('The image was not saved!');
        uiwait(he)
        return
    end
    lutbasename = [pn,filesep,fn,'_colorlut'];
    colorlut = table(cellfun(@uint16,datalut(:,1)),datalut(:,2),...
        cell2mat(datalut(:,3)),cell2mat(datalut(:,4)),...
        cell2mat(datalut(:,5)),cell2mat(datalut(:,6)),...
        'VariableNames',{'Index','ROI_Names','R','G','B','A'});
    
    save([lutbasename,'.mat'],'colorlut');
    
    writetable(colorlut,[lutbasename,'.txt'],...
        'WriteRowNames',true,'Delimiter','tab');
    
end

%--------------------------------------------------------------------------
% Delete the roi_under-construction.nii image
listimgdata = get(handles.table_listimg,'Data');
ucidx = find(contains(listimgdata(:,3),'roi_under-construction'), 1);


if ~isempty(ucidx)
    handles.table_selectedcell(1) = ucidx;
    guidata(hObject, handles);
    
    pbutton_delete_callback(hObject)
end
