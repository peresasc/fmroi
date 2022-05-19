function editpos_callback(hObject, ~)
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
n = handles.table_selectedcell(1);
tag = get(hObject,'Tag');

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
draw_slices(hObject)