function pbutton_roiclear_callback(hObject, ~)
% pbutton_roiclear_callback is an internal function of fMROI.
%
% Syntax:
%   pbutton_roiclear_callback(hObject, ~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

handles = guidata(hObject);

%--------------------------------------------------------------------------
% Delete the roi_under-construction.nii image
listimgdata = get(handles.table_listimg,'Data');
ucidx = find(contains(listimgdata(:,3),'roi_under-construction'), 1);

if ~isempty(ucidx)
    handles.table_selectedcell(1) = ucidx;
    guidata(hObject, handles);
    
    pbutton_delete_callback(hObject)
end

