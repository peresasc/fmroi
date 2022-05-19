function table_listimg_selcallback(hObject, eventData)
% table_listimg_selcallback is an internal function of fMROI.
%
% Syntax:
%   table_listimg_selcallback(hObject, eventData)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%   eventData: conveys information about changes or actions that occurred
%              within the table_listimg.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

if ~isempty(eventData.Indices)
    if eventData.Indices(2) == 3
        updateuicontrols(hObject,eventData.Indices(1));
        imgnamelist = getimgnamelist(hObject);
        handles = guidata(hObject);
        
        handles.table_selectedcell = eventData.Indices;
        
        % Turns bold the name of the selected image
        htmlbold = '<HTML><TABLE><TD><B>';
        imgnamelist{handles.table_selectedcell(1)} =...
            [htmlbold,imgnamelist{handles.table_selectedcell(1)}];
        
        tdata = get(handles.table_listimg,'Data');
        tdata(:,3) = imgnamelist;
        set(handles.table_listimg,'Data',tdata);
       
        guidata(hObject, handles);
        
    end
end

