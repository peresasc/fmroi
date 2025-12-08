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

% 1. Check Version
v_str = version('-release');
v_year = str2double(v_str(1:4));

% 2. Apply Legacy Hack Only
if v_year < 2025
    % --- LEGACY MODE (Java Swing, 2024b and older) ---

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

        guidata(hObject, handles);
        popup_roitype_callback(hObject);
        handles = guidata(hObject);

        jtable.changeSelection(0,1, false, false);
        guidata(hObject, handles);

    end
else
    % --- MODERN MODE (web, 2025a +) ---

    if isfield(st,'roimasks') && ~isempty(st.roimasks)

        % Retrieve selected row from handles
        row_to_delete = [];
        if isfield(handles,'selected_roi_row')
            row_to_delete = handles.selected_roi_row;
        end

        % Validate selection
        if isempty(row_to_delete) || row_to_delete<1 ||...
                row_to_delete>length(st.roimasks)

            he = errordlg('Select one ROI to be deleted!');
            uiwait(he);
            return;
        end

        % Delete from global structure
        st.roimasks(row_to_delete) = [];

        % Reset selection to avoid index errors
        handles.selected_roi_row = [];
        guidata(hObject, handles);

        % Update UI components
        updateroitable(hObject);

        popup_roitype_callback(hObject);        
    end

end