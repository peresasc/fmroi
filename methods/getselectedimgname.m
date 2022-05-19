function imgname = getselectedimgname(hObject)
% getselectedimgname is an internal function of fMROI that retrieves the
% names of the selected image.
%
% Syntax:
%   imgname = getselectedimgname(hObject)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Outputs:
%   imgname: Character array containing the selected image name.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com
handles = guidata(hObject);

tdata = get(handles.table_listimg,'Data');
imgname = tdata{handles.table_selectedcell(1),3};

if strcmp(imgname(1),'<')
    imgname = imgname(21:end);
end

