function pbutton_roi_callback(hObject, ~)
% pbutton_roi_callback is an internal function of fMROI.
%
% Syntax:
%   pbutton_roi_callback(hObject, ~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

global st
handles = guidata(hObject);

n = handles.table_selectedcell(1);

guidata(hObject,handles);
listimgdata = getimgnamelist(hObject);
st.roisrcname = listimgdata{n};

%--------------------------------------------------------------------------
% Special variables

specialvars = {'hObject';'srcvol';'curpos';'minthrs';'maxthrs'};

srcvol = st.vols{n}.private.dat(:,:,:);

center_cpima = st.vols{n}.mat\[st.centre';1];
curpos = round(center_cpima(1:3))';

minthrs = handles.imgprop(n).minthrs;
minthrs = minthrs*(st.vols{n}.clim(2)-st.vols{n}.clim(1))...
    + st.vols{n}.clim(1);

maxthrs = handles.imgprop(n).maxthrs;
maxthrs = maxthrs*(st.vols{n}.clim(2)-st.vols{n}.clim(1))...
    + st.vols{n}.clim(1);


%--------------------------------------------------------------------------
% Mask creation

if isfield(st,'roimasks')
    if ~isequal(size(srcvol), size(st.roimasks{1}))
        he = errordlg('The source images must have the same size!');
        uiwait(he)
    return
    end
end

if find(contains(st.roisrcname,'roi_under-construction'), 1)    
    he = errordlg('The roi_under-construction image cannot be used as a source for new ROIs!');
    uiwait(he)
    return    
end
%--------------------------------------------------------------------------
% Mask creation

v = get(handles.popup_roitype,'Value');
s = get(handles.popup_roitype,'String');
roimth = s{v};

fs = dir([handles.roimethdir,filesep,'**',filesep,roimth,'_caller.m']);

if isempty(fs)
    mthcallerpath = '';
else
    mthcallerpath = fullfile(fs.folder,fs.name);
end

if isfile(mthcallerpath)
    [args, ~] = get_arg_names(mthcallerpath);
    args = args{1};
    args(~ismember(args,specialvars)) = [];
    for k = 1:length(args)
        args{k} = eval(args{k});
    end
    mask = feval([roimth,'_caller'],args{:});
    handles = guidata(hObject);
else
    fs = dir([handles.roimethdir,filesep,'**',filesep,roimth,'.m']);

    if isempty(fs)
        methodpath = '';
    else
        methodpath = fullfile(fs.folder,fs.name);
    end
    
    [args, ~] = get_arg_names(methodpath);    
    args = args{1};
    argsidx = 1:length(args);
    argsidx(ismember(args,specialvars)) = [];
    count = 0;
    for i = argsidx
        count = count+1;
        args{i} = get(handles.edit_autogui(count),'String');
    end
    for k = 1:length(args)
        args{k} = eval(args{k});
    end
    mask = feval(roimth,args{:});
end

mask = uint16(mask);

%--------------------------------------------------------------------------
% Stores each ROI in a separate matrix in the st structure
newroi_idx = unique(mask(:));
newroi_idx(newroi_idx==0) = [];

if isempty(newroi_idx)
   return 
end
datalut = get(handles.table_roilut,'Data');

if  isempty(datalut{1,1})
    roi_idx = [];
else
    roi_idx = cellfun(@uint16,datalut(:,1));
end

for i = newroi_idx'    
    currmask = mask;
    currmask(currmask~=i) = 0;
    if isfield(st,'roimasks') && ~isempty(roi_idx)        
        currmask(logical(currmask)) =...
            currmask(logical(currmask)) + max(roi_idx);
        st.roimasks{end+1} = currmask;
    else
        st.roimasks{i} = currmask;
    end
end

guidata(hObject, handles);
updateroitable(hObject)