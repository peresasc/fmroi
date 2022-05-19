function axes4_buttondownfcn_callback(hObject, ~)
% axes4_buttondownfcn_callback is an internal function of fMROI and is
% called after a left mouse click event on the image render axis.
%
% Syntax:
%   axes4_buttondownfcn_callback(hObject, ~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

global st
handles = guidata(hObject);
n_image = find(~cellfun(@isempty,st.vols), 1, 'last');
camtarg = get(handles.ax{n_image,4}.ax,'CameraTarget');

[az, el] = view(handles.ax{n_image,4}.ax);

for i = 1:n_image
    view(handles.ax{i,4}.ax,[az el])
%     set(handles.ax{i,4}.ax,'CameraTarget',camtarg)
end