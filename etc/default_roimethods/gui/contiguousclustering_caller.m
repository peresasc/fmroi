function mask = contiguousclustering_caller(hObject)
% contiguousclustering_caller is an internal function of fMROI. It calls
% the contiguousclustering function.
% 
% Syntax:
%   mask = contiguousclustering_caller(hObject)
% 
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Output: 
%      mask: Integer 3D matrix with the same size as srcvol. The non-zero
%            values of mask are the indexes of each clusters.
% 
%  Author: Andre Peres, 2019, peres.asc@gmail.com
%  Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

global st
handles = guidata(hObject);

n = handles.table_selectedcell(1);    

minthrs = handles.imgprop(n).minthrs;
minthrs = minthrs*(st.vols{n}.clim(2)-st.vols{n}.clim(1))...
    + st.vols{n}.clim(1);

maxthrs = handles.imgprop(n).maxthrs;
maxthrs = maxthrs*(st.vols{n}.clim(2)-st.vols{n}.clim(1))...
    + st.vols{n}.clim(1);

mincltsz = str2double(get(handles.edit_mincltsz,'String'));

vol = spm_data_read(st.vols{n});
mask = contiguousclustering(vol,minthrs,maxthrs,mincltsz);