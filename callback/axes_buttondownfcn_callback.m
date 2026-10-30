function axes_buttondownfcn_callback(hObject, ~)
% axes_buttondownfcn_callback is an internal function of fMROI and is
% called after a left mouse click event on one of the three axes of planar
% images (axial, coronal and sagittal).
%
% Syntax:
%   axes_buttondownfcn_callback(hObject, ~)
%
% Inputs:
%   hObject: handle of the clicked axis.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 30/10/2026, peres.asc@gmail.com

update_coordinates(hObject)
draw_slices(hObject)