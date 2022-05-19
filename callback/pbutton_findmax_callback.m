function pbutton_findmax_callback(hObject, ~)
% pbutton_findmax_callback is an internal function of fMROI.
%
% Syntax:
%   pbutton_findmax_callback(hObject, ~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

global st
handles = guidata(hObject);

n = handles.table_selectedcell(1);

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

mthcallerpath = fullfile(handles.fmroirootdir,...
    'roimethods','gui',[roimth,'_caller.m']);

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
    methodpath = fullfile(handles.fmroirootdir,...
        'roimethods','methods',[roimth,'.m']);    
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

mask = logical(mask);
%--------------------------------------------------------------------------
% Searching for the position of the voxel with max value
roi = srcvol.*mask;
[~, m] = max(roi(:));
[x,y,z] = ind2sub(size(roi),m);

cpima = [x,y,z,1];
cpwld = st.vols{n}.mat*cpima';
cpwld = cpwld';

st.centre = cpwld(1:3);

cp = [cpwld; cpima];
for i = 1:2
    for j = 1:3
        set(handles.edit_pos(i,j),'String',num2str(cp(i,j)))
    end
end

guidata(hObject, handles);
draw_slices(hObject)