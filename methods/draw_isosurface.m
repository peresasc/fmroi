function draw_isosurface(hObject, mask)
% draw_isosurface is an internal function of fMROI.
%
% Syntax:
%   draw_isosurface(hObject, mask)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%      mask: binary 3D matrix to be rendered.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

global st
handles = guidata(hObject);

n = handles.table_selectedcell(1); % position of selected image

cpwld0 = st.vols{n}.mat*ones(4,1); % image origin in the world RAS coordinates
cpwld1 = st.vols{n}.mat*[size(mask)';1]; % image end in the world RAS coordinates

premul = st.Space \ st.vols{n}.premul; % A\B == inv(A)*B
% SPM function to compute volume's bounding box for full field of view.
auxbb = spm_get_bbox(st.vols{n}, 'fv', premul);
bb = auxbb - st.bb(1,:) + 1;

% cpwld0 = cpwld0/4;
% cpwld1 = cpwld1/4;
sp = st.Space;
% sp(1:3,4) = displacement(1:3);
mat = sp\st.vols{n}.mat;
mat = mat(:,[2,1,3,4]);
mat = mat';

% res = abs(sum(st.vols{n}.mat(1:3,1:3),2));
% ra = imref3d(size(mask),res(1),res(2),res(3));
tform = affine3d(mat);
[mask_dpl] = imwarp(mask,tform);
mask_dpl = round(mask_dpl);

axes(handles.ax{n,4}.ax)
hold on

isurf = isosurface(linspace(bb(1,1),bb(2,1),size(mask_dpl,2)),...
    linspace(bb(1,2),bb(2,2),size(mask_dpl,1)),...
    linspace(bb(1,3),bb(2,3),size(mask_dpl,3)),mask_dpl,0);

p = patch(isurf);
isonormals(mask_dpl,p)
s = get(handles.popup_roicolor,'String');
p.FaceColor = s{handles.imgprop(n).roicolor};
p.FaceAlpha = handles.imgprop(n).roialpha;
p.EdgeColor = 'none';
daspect([1 1 1])

handles.ax{n,4}.roipatch = p;
% Avoid creating several light sources
if isfield(handles,'light')
    delete(handles.light)    
end
handles.light = camlight('headlight');%%light(handles.ax{n,4}.ax,'style','local');
lighting gouraud
material dull


guidata(hObject, handles);