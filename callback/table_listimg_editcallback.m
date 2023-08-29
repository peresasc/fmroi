function table_listimg_editcallback(hObject,eventData)
% table_listimg_editcallback is an internal function of fMROI.
%
% Syntax:
%   table_listimg_editcallback(hObject,eventData)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%   eventData: conveys information about changes or actions that occurred
%              within the table_listimg.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

if eventData.Indices(2) == 1
    
    handles = guidata(hObject);
    n = eventData.Indices(1);
    
    handles.imgprop(n).viewslices = handles.table_listimg.Data{eventData.Indices};
    guidata(hObject, handles);
    
    
    if handles.imgprop(n).viewslices
        for i = 1:4
            handles.ax{n,i}.d.Visible = 'on';
        end
    else
        for i = 1:4
            handles.ax{n,i}.d.Visible = 'off';
        end
    end
    
    
    guidata(hObject, handles);
end
