function pbutton_lcrun_callback(hObject, ~)
% pbutton_lcrun_callback is an internal function of fMROI.
%
% Syntax:
%   pbutton_lcrun_callback(hObject, ~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

global st
handles = guidata(hObject);

d = get(handles.table_roilc,'Data');

[lastrow, ~] = find(~cellfun(@isempty,d), 1, 'last');
if isempty(lastrow) || lastrow < 2
    return
end

data = cell(lastrow,1);
dataname = cell(lastrow,1);
op = cell(lastrow-1,1);

guidata(hObject,handles);
imgnamelist = getimgnamelist(hObject);
for i = 1:lastrow
    dataname{i} = d{i,1};
    op{i} = d{i,2};
    if strcmpi(d{i,3},'image')
        n = find(strcmp(imgnamelist, dataname{i}));
        
        maxthrs = handles.imgprop(n).maxthrs;
        maxthrs = maxthrs*(st.vols{n}.clim(2)-st.vols{n}.clim(1))+...
            st.vols{n}.clim(1);
        
        minthrs = handles.imgprop(n).minthrs;
        minthrs = minthrs*(st.vols{n}.clim(2)-st.vols{n}.clim(1))+...
            st.vols{n}.clim(1);
        
        vol = st.vols{n}.private.dat(:,:,:);
        data{i} = img2mask(vol,minthrs,maxthrs);
    elseif strcmpi(d{i,3},'roi')
        roilutdata = get(handles.table_roilut,'Data');
        n = strcmp(roilutdata(:,2), dataname{i});
        data{i} = st.roimasks{n};
    else
        return
    end
end

op(end) = [];

mask = logic_chain(data,op);
mask = single(mask);

%--------------------------------------------------------------------------
% Saving the mask to a nifti image

for n = 1:length(imgnamelist)
    if strcmp(imgnamelist(n),dataname{2})
        break
    end
end


[fn, pn, idx] = uiputfile('*.*');
if idx == 0
    return
end

filename = fullfile(pn,fn);
vsrc = spm_vol(st.vols{n}.fname);
vsrc.fname = filename;
V = spm_create_vol(vsrc);
V = spm_write_vol(V, mask);

%--------------------------------------------------------------------------
% Display ROI
[x,y,z] = ind2sub(size(mask),find(mask > 0));
pos = [x,y,z];
cpima = [pos,ones(size(pos,1),1)];
cpwld = st.vols{n}.mat*cpima';
cent = (st.Space\cpwld);
bbmin = st.bb(1,:)-1;
cp = cent(1:3,:)'-repmat(bbmin,size(cent,2),1);
cp = round(cp);

imroi = zeros(round(diff(st.bb)+1));
cp = ensure_ind(size(imroi),cp);
cp_ind = sub2ind(size(imroi), cp(:,1), cp(:,2), cp(:,3));
imroi(cp_ind)=1;
imroi = permute(imroi,[2,1,3]);

show_slices(hObject, filename)
handles = guidata(hObject);

%--------------------------------------------------------------------------
% Display ROI as 3D surface
n_image = find(~cellfun(@isempty,st.vols), 1, 'last');
axes(handles.ax{n_image,4}.ax)
hold on
% plot3(cp(:,1), cp(:,2), cp(:,3), 'k.')%,'Color','k','MarkerSize',10,'MarkerFaceColor','r')

% for i = 1:length(poly)
%
%     plotcube([1 1 1],[poly(i,1), poly(i,2), poly(i,3)],.2,[1 0 0]);
% end

isurf = isosurface(imroi,0);
p = patch(isurf);
isonormals(imroi,p)
p.FaceColor = 'red';
p.EdgeColor = 'none';
daspect([1 1 1])

handles.ax{n_image,4}.roipatch = p;
camlight
lighting gouraud


guidata(hObject, handles);