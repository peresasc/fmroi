function editpos_callback(hObject,~,tag)
% editpos_callback is an internal function of fMROI.
%
% Syntax:
%   editpos_callback(hObject, ~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

global st
handles = guidata(hObject);
n_image = find(~cellfun(@isempty,st.vols), 1, 'last');
n = handles.table_selectedcell(1);

if ~exist('tag', 'var') || isempty(tag)
    tag = get(hObject,'Tag');
end


if tag(end-1)=='1'
    cpwld = [str2double(get(handles.edit_pos(1,1),'String')),...
             str2double(get(handles.edit_pos(1,2),'String')),...
             str2double(get(handles.edit_pos(1,3),'String')),...
             1];

    cpima = st.vols{n}.mat\cpwld';
    cpima = cpima';
elseif tag(end-1)=='2'
   cpima = [str2double(get(handles.edit_pos(2,1),'String')),...
             str2double(get(handles.edit_pos(2,2),'String')),...
             str2double(get(handles.edit_pos(2,3),'String')),...
             1];
    cpwld = st.vols{n}.mat*cpima';
    cpwld = cpwld';
end

st.centre = cpwld(1:3);

cp = [cpwld; cpima];
for i = 1:2
    for j = 1:3
        set(handles.edit_pos(i,j),'String',num2str(cp(i,j)))
    end
end

voxelvalue = cell(n_image,1);
for k = 1:n_image
    cpk = st.vols{k}.mat\cpwld';
    cpk = round(cpk(1:3))';

    s = size(st.vols{k}.private.dat);
    if sum((cpk<1)+(cpk>s))
        voxelvalue{k} = NaN;
    else
        voxelvalue{k} = st.vols{k}.private.dat(cpk(1),cpk(2),cpk(3));
    end
end

tdata = get(handles.table_listimg,'Data');
tdata(:,2) = voxelvalue;
set(handles.table_listimg,'Data',tdata);

draw_slices(hObject)