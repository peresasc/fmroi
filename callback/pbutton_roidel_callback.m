function pbutton_roidel_callback(hObject, ~)
% pbutton_roidel_callback is an internal function of fMROI.
%
% Syntax:
%   pbutton_roidel_callback(hObject, ~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

global st
handles = guidata(hObject);

if isfield(st,'roimasks') && ~isempty(st.roimasks)

    jobj = findjobj(handles.table_roilut);
    jtable = jobj.getViewport.getView;

    if jtable.getSelectedRow == -1
        he = errordlg('Select one ROI to be deleted!');
        uiwait(he)
        return
    end

    st.roimasks(jtable.getSelectedRow+1) = [];

    guidata(hObject, handles);
    updateroitable(hObject)
    handles = guidata(hObject);

    jtable.changeSelection(0,1, false, false);
    guidata(hObject, handles);

end