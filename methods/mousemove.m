function mousemove(hObject, ~)
% mousemove is an internal function of fMROI.
%
% Syntax:
%   mousemove(hObject, ~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

global st

if isfield(st,'vols')% && handles.mousehold
    handles = guidata(hObject);
    n_image = find(~cellfun(@isempty,st.vols), 1, 'last');
    
    if ~isempty(n_image) && isfield(handles, 'ax')
        
        h = getoverobj('type','axes');
        if ~isempty(h)
            update_coordinates(hObject,h)
            handles = guidata(hObject);
            
            %--------------------------------------------------------------
            % Check if the mouse hover over axes rendering and enable
            % rotation otherwise disable rotation.
%             tag = get(h,'Tag');
%             
%             if contains(tag,'rendering')
%                 handles.hrotate.Enable = 'on';
%                 guidata(hObject,handles);
%             else
%                 handles.hrotate.Enable = 'off';
%                 guidata(hObject,handles);
%             end
            
            %--------------------------------------------------------------
            % If the right mouse button is pressed and hold, mousemove
            % updates the image position
            if handles.mousehold
                draw_slices(hObject)
            end
        end
    end
end
