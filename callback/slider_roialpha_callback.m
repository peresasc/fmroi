function slider_roialpha_callback(hObject, ~)
% slider_roialpha_callback is an internal function of fMROI.
%
% Syntax:
%   slider_roialpha_callback(hObject, ~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

% global st
handles = guidata(hObject);

n = handles.table_selectedcell(1); % position of selected image
% n = find(~cellfun(@isempty,st.vols), 1, 'last');
handles.ax{n,4}.roipatch.FaceAlpha = get(handles.slider_roialpha,'Value');
handles.imgprop(n).roialpha = get(handles.slider_roialpha,'Value');

guidata(hObject, handles);