function table_roilut_editcallback(hObject,eventData)
% table_roilut_editcallback is an internal function of fMROI.
%
% Syntax:
%   table_roilut_editcallback(hObject, eventData)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%   eventData: conveys information about changes or actions that occurred
%              within the table_roilut.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

global st
handles = guidata(hObject);

n = eventData.Indices(1);
lutdata = get(handles.table_roilut,'Data');

if eventData.Indices(2) == 1
    
    if ~isfield(st,'roimasks')
        he = errordlg('There is no ROI - create an ROI before changing its parameters.');
        uiwait(he)
        return
    end
    
    st.roimasks{n}(logical(st.roimasks{n})) = lutdata{eventData.Indices};
    
    guidata(hObject, handles);
    updateroitable(hObject)
end
