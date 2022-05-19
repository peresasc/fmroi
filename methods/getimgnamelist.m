function imgnamelist = getimgnamelist(hObject)
% getimgnamelist is an internal function of fMROI that retrieves the names
% of the opened images.
%
% Syntax:
%   imgnamelist = getimgnamelist(hObject)
%
% Inputs:
%       hObject: handle of the figure that contains the fMROI main window.
%
% Outputs:
%   imgnamelist: mx1 cell array containing in each line one image name.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

handles = guidata(hObject);
tdata = get(handles.table_listimg,'Data');

imgnamelist = tdata(:,3);

% Removes the html bold prefix inserted by the function
% table_listimg_selcallback: htmlbold = '<HTML><TABLE><TD><B>'
for i = 1:length(imgnamelist)
    if strcmp(imgnamelist{i}(1),'<')
        imgnamelist{i} = imgnamelist{i}(21:end);
    end
end