function axesdrawing_buttondownfcn_callback(hObject,event)
% axesdrawing_buttondownfcn_callback is an internal function of fMROI.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 30/10/2026, peres.asc@gmail.com

global st
handles = guidata(hObject);
h = getoverobj('type','axes');

if isempty(h)
    return;
end

tag = get(h,'Tag');
if length(tag) >= 2
    tag = tag(1:end-2);
end
if strcmpi(tag,'transversal')
    tag = 'axial';
elseif strcmpi(tag,'sagital')
    tag = 'sagittal';
end

v = handles.popup_workingaxes.Value;
s = handles.popup_workingaxes.String;
waxis = s{v};

if strcmpi(waxis,tag)
    if (strcmpi(event.EventName,'WindowMouseMotion') && handles.mousehold && ...
            ~isempty(h) && not(handles.toolbar)) || ...
            strcmp(event.EventName,'Hit')

        listimgdata = get(handles.table_listimg,'Data');
        ucidx = find(contains(listimgdata(:,3),'roi_under-construction'), 1);
        if isempty(ucidx)
            ucidx = find(~cellfun(@isempty,st.vols), 1, 'last');
        end
        selaxis = get(handles.popup_workingaxes,'Value');
        wroi = get(handles.popup_workingroi,'Value')-1;
        datalut = get(handles.table_roilut,'Data');

        % Ensure drawingroi structure is present
        if ~isfield(handles, 'drawingroi')
            handles.drawingroi = struct();
        end

        % Check if brush overlay and mask exist and match current selaxis
        if ~isfield(handles.drawingroi, 'brushmask') || isempty(handles.drawingroi.brushmask) || ...
                ~isfield(handles.drawingroi, 'selaxis') || handles.drawingroi.selaxis ~= selaxis || ...
                ~isfield(handles.drawingroi, 'hbrush') || ~ishandle(handles.drawingroi.hbrush)
            
            if isfield(handles.drawingroi, 'hbrush') && ishandle(handles.drawingroi.hbrush)
                delete(handles.drawingroi.hbrush);
            end
            
            slices = getslices(st, ucidx);
            mask2d = slices{selaxis};
            handles.drawingroi.brushmask = mask2d;
            handles.drawingroi.selaxis = selaxis;
            handles.drawingroi.wroi = wroi;
            handles.drawingroi.ucidx = ucidx;

            % Get brush color from edits (or fallback)
            if isfield(handles, 'edit_brushcolor_r') && ishandle(handles.edit_brushcolor_r)
                r_w = str2double(get(handles.edit_brushcolor_r, 'String'));
                g_w = str2double(get(handles.edit_brushcolor_g, 'String'));
                b_w = str2double(get(handles.edit_brushcolor_b, 'String'));
                if isnan(r_w) || r_w < 0, r_w = 0; elseif r_w > 255, r_w = 255; else, r_w = round(r_w); end
                if isnan(g_w) || g_w < 0, g_w = 0; elseif g_w > 255, g_w = 255; else, g_w = round(g_w); end
                if isnan(b_w) || b_w < 0, b_w = 0; elseif b_w > 255, b_w = 255; else, b_w = round(b_w); end
                active_color = [r_w, g_w, b_w] / 255;
            else
                active_color = [1, 0, 1];
            end

            % Get brush alpha from edit (or fallback)
            if isfield(handles, 'edit_brushalpha') && ishandle(handles.edit_brushalpha)
                alphavalue = str2double(get(handles.edit_brushalpha, 'String'));
                if isnan(alphavalue) || alphavalue < 0
                    alphavalue = 0;
                elseif alphavalue > 1
                    alphavalue = 1;
                end
            else
                alphavalue = handles.imgprop(ucidx).alpha;
                if isempty(alphavalue) || alphavalue == 0
                    alphavalue = 0.5;
                end
            end

            roi_val = datalut{wroi, 1};
            if iscell(roi_val), roi_val = roi_val{1}; end

            overlay_rgb = zeros(size(mask2d, 1), size(mask2d, 2), 3);
            alpha2d = zeros(size(mask2d));

            for k = 1:size(datalut, 1)
                k_val = datalut{k, 1};
                if iscell(k_val), k_val = k_val{1}; end
                if k_val == roi_val
                    k_color = active_color;
                else
                    r_k = datalut{k, 3}; if ischar(r_k), r_k = str2double(r_k); end
                    g_k = datalut{k, 4}; if ischar(g_k), g_k = str2double(g_k); end
                    b_k = datalut{k, 5}; if ischar(b_k), b_k = str2double(b_k); end
                    k_color = double([r_k, g_k, b_k]) / 255;
                end
                k_mask = (mask2d == k_val);
                if any(k_mask(:))
                    overlay_rgb(:,:,1) = overlay_rgb(:,:,1) + k_color(1) * k_mask;
                    overlay_rgb(:,:,2) = overlay_rgb(:,:,2) + k_color(2) * k_mask;
                    overlay_rgb(:,:,3) = overlay_rgb(:,:,3) + k_color(3) * k_mask;
                    alpha2d(k_mask) = alphavalue;
                end
            end

            handles.drawingroi.overlay_rgb = overlay_rgb;
            handles.drawingroi.active_color = active_color;
            handles.drawingroi.alphavalue = alphavalue;

            handles.drawingroi.hbrush = image('Parent', handles.ax{1, selaxis}.ax, ...
                'CData', overlay_rgb, 'AlphaData', alpha2d, ...
                'HitTest', 'off', 'PickableParts', 'none');

            uistack(handles.ax{1, selaxis}.d, 'bottom');
            if isfield(handles.ax{1, selaxis}, 'lx') && ishandle(handles.ax{1, selaxis}.lx)
                uistack(handles.ax{1, selaxis}.lx, 'top');
            end
            if isfield(handles.ax{1, selaxis}, 'ly') && ishandle(handles.ax{1, selaxis}.ly)
                uistack(handles.ax{1, selaxis}.ly, 'top');
            end
            draw_slices(hObject);
        end

        cp = get(h,'CurrentPoint');
        cp = round(cp(1,1:2));
        mask = handles.drawingroi.brushmask;

        r = str2double(get(handles.edit_brushradius,'String'));
        if isnan(r) || r < 1
            r = 1;
        end
        [x,y] = size(mask);
        [My,Mx] = ndgrid(1:x,1:y);
        auxmask = (sqrt((Mx-cp(1)).^2 + (My-cp(2)).^2) < r);

        if isfield(handles.drawingroi, 'active_color')
            active_color = handles.drawingroi.active_color;
        elseif isfield(handles, 'edit_brushcolor_r') && ishandle(handles.edit_brushcolor_r)
            r_w = str2double(get(handles.edit_brushcolor_r, 'String'));
            g_w = str2double(get(handles.edit_brushcolor_g, 'String'));
            b_w = str2double(get(handles.edit_brushcolor_b, 'String'));
            active_color = [r_w, g_w, b_w] / 255;
        else
            active_color = [1, 0, 1];
        end

        overlay_rgb = handles.drawingroi.overlay_rgb;
        alpha2d = get(handles.drawingroi.hbrush, 'AlphaData');

        if isfield(handles, 'edit_brushalpha') && ishandle(handles.edit_brushalpha)
            alphavalue = str2double(get(handles.edit_brushalpha, 'String'));
            if isnan(alphavalue) || alphavalue < 0, alphavalue = 0; elseif alphavalue > 1, alphavalue = 1; end
        elseif isfield(handles.drawingroi, 'alphavalue')
            alphavalue = handles.drawingroi.alphavalue;
        else
            alphavalue = handles.imgprop(ucidx).alpha;
            if isempty(alphavalue) || alphavalue == 0, alphavalue = 0.5; end
        end

        roi_val = datalut{wroi, 1};
        if iscell(roi_val), roi_val = roi_val{1}; end

        if handles.mousehold == 1
            mask(auxmask) = roi_val;
            
            c_r = overlay_rgb(:,:,1); c_r(auxmask) = active_color(1); overlay_rgb(:,:,1) = c_r;
            c_g = overlay_rgb(:,:,2); c_g(auxmask) = active_color(2); overlay_rgb(:,:,2) = c_g;
            c_b = overlay_rgb(:,:,3); c_b(auxmask) = active_color(3); overlay_rgb(:,:,3) = c_b;
            
            alpha2d(auxmask) = alphavalue;
        else
            mask(auxmask) = 0;
            alpha2d(auxmask) = 0;
        end

        handles.drawingroi.brushmask = mask;
        handles.drawingroi.overlay_rgb = overlay_rgb;
        
        set(handles.drawingroi.hbrush, 'CData', overlay_rgb, 'AlphaData', alpha2d);
    end
end

% %--------------------------------------------------------------------------
% % update current position mousemove
if ~isempty(h)
    centre = getworldpos(h);
    if ~isempty(centre) && numel(centre) >= 3
        n = handles.table_selectedcell(1);
        cpima = st.vols{n}.mat\[centre';1];
        cpima = round(cpima(1:3))';

        set(handles.text_pos(1),'String',num2str(round(centre)))
        set(handles.text_pos(2),'String',num2str(cpima))
    end
end

guidata(hObject, handles);