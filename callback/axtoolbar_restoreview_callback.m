function axtoolbar_restoreview_callback(hObject, ~)
% axtoolbar_restoreview_callback is an internal function of fMROI.
% Restores original zoom on all axes, resets grid view if a window is
% extended, and centers the crosshair cursor at the physical 3D volume center.
%
% Syntax:
%   axtoolbar_restoreview_callback(hObject, ~)
%
% Inputs:
%   hObject: handle of the toolbar push button or menu item.
%
% Author: Andre Peres, 2026, peres.asc@gmail.com
% Last update: Andre Peres, 30/10/2026, peres.asc@gmail.com

global st
handles = guidata(hObject);

if ~isfield(st, 'vols') || isempty(st.vols)
    return;
end

%--------------------------------------------------------------------------
% 1. If a window is extended, restore to Grid view mode
idx_extended = [];
for i = 1:4
    if isfield(handles, 'panel_graph') && numel(handles.panel_graph) >= i && ...
            ishandle(handles.panel_graph(i))
        pos = get(handles.panel_graph(i), 'Position');
        if pos(4) > 0.9  % Default grid height is 0.49; extended height is 0.98
            idx_extended = i;
            break;
        end
    end
end

if ~isempty(idx_extended)
    ax_ext = handles.ax{1, idx_extended}.ax;
    tb_ext = handles.ax{1, idx_extended}.tb;
    btn_grid = findobj(tb_ext.Children, 'Tooltip', 'Grid view');
    
    if ~isempty(btn_grid)
        event.Source = btn_grid;
        event.Axes = ax_ext;
        event.EventName = 'ButtonPushed';
        
        axtoolbar_slicegrid_callback(btn_grid, event);
        drawnow;
        handles = guidata(hObject);
    end
end

%--------------------------------------------------------------------------
% 2. Restore original zoom on all 2D axes
maxdim = max(round(diff(st.bb) + 1));

for i = 1:3
    if isfield(handles, 'ax') && size(handles.ax, 2) >= i && ...
            isfield(handles.ax{1, i}, 'ax') && ishandle(handles.ax{1, i}.ax)
        axis(handles.ax{1, i}.ax, [0 maxdim 0 maxdim]);
        axis(handles.ax{1, i}.ax, 'image');
    end
end

% Restore 4th axis (3D rendering) if it exists
if isfield(handles, 'ax') && size(handles.ax, 2) >= 4 && ...
        isfield(handles.ax{1, 4}, 'ax') && ishandle(handles.ax{1, 4}.ax)
    st.dims = round(diff(st.bb)' + 1);
    set(handles.ax{1, 4}.ax, 'XLim', [0 st.dims(1)], ...
                             'YLim', [0 st.dims(2)], ...
                             'ZLim', [0 st.dims(3)]);
    view(handles.ax{1, 4}.ax, [-35, 35]);
end

%--------------------------------------------------------------------------
% 3. Compute 3D physical center and delegate update to editpos_callback
centre_scanner = mean(st.Space * [st.bb'; 1 1], 2)';

for j = 1:3
    set(handles.edit_pos(1, j), 'String', num2str(centre_scanner(j)));
end

editpos_callback(handles.fig, [], 'edit11');
