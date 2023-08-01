function popup_drawmethod_callback(hObject, ~)
% popup_drawmethod_callback is an internal function of fMROI.
%
% Syntax:
%   popup_roitype_callback(hObject, ~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

handles = guidata(hObject);

if isfield(handles,'panel_drawtools')
    if isobject(handles.panel_drawtools)
        if isvalid(handles.panel_drawtools)
            delete(handles.panel_drawtools)
        end
    end
end


handles.panel_drawtools = uipanel(handles.panel_roimethod, 'BackgroundColor', 'w', ...
    'Units', 'normalized', 'Position', [0.52, 0.01, 0.47, 0.6],...
    'DeleteFcn',@panel_drawtools_deletefcn,'Visible', 'on');

v = get(handles.popup_drawmethod,'Value');
s = get(handles.popup_drawmethod,'String');
roimth = s{v};

switch lower(roimth)
    case 'brush'

        %--------------------------------------------------------------------------
        % creates the brush tooglebutton
        handles.tbutton_brushroidraw = uicontrol(handles.panel_drawtools, 'Style', 'togglebutton',...
            'Units', 'normalized','Position', [0.03, 0.75, 0.45, 0.2],...
            'String','Draw','Callback',@tbutton_roibrush_callback);

        %--------------------------------------------------------------------------
        % creates the brush ROI add pushbutton
        handles.pbutton_brushroiadd = uicontrol(handles.panel_drawtools, 'Style', 'PushButton',...
            'Units', 'normalized','Position', [0.52, 0.75, 0.45, 0.2],...
            'String','Add','Callback',@pbutton_brushroiadd_callback);

        %--------------------------------------------------------------------------
        %creates the text for the control pushbuttons
        handles.text_brushradius = uicontrol(handles.panel_drawtools,...
            'Style','text','Units','normalized',...
            'String','Brush size:','BackgroundColor','w',...
            'FontSize',9,'HorizontalAlignment','left',...
            'Position', [0.03, 0.45 0.94, 0.12]);

        %--------------------------------------------------------------------------
        % creates the edit text for radius/volume in voxels
        handles.edit_brushradius = uicontrol(handles.panel_drawtools, 'Style', 'edit',...
            'Units', 'normalized', 'String', '1',...
            'BackgroundColor', 'w', 'FontSize', 11,...
            'HorizontalAlignment', 'left','Position', [0.03, 0.25 0.94, 0.2]);

    case 'closed_shape'

        %--------------------------------------------------------------------------
        % creates the drawing method buttongroup
        handles.buttongroup_drawtype = uibuttongroup(handles.panel_drawtools,...
            'BackgroundColor', 'w', 'Units', 'normalized',...
            'Position', [0.03, 0.25 0.94, 0.2]);

        %--------------------------------------------------------------------------
        % creates the draw freehand radio button
        handles.radio_drawfreehand = uicontrol(...
            handles.buttongroup_drawtype, 'Style', 'radiobutton',...
            'Units', 'normalized','Position', [0.01, 0.1, 0.54, 0.8],...
            'String','Freehand', 'BackgroundColor', 'w',...
            'Callback',@radiobutton_drawfreehand_callback);

        %--------------------------------------------------------------------------
        % creates the draw polygon radio button
        handles.radio_drawpolygon = uicontrol(...
            handles.buttongroup_drawtype, 'Style', 'radiobutton',...
            'Units', 'normalized','Position', [0.55, 0.1, 0.45, 0.8],...
            'String','Polygon', 'BackgroundColor', 'w',...
            'Callback',@radiobutton_drawfreehand_callback);


        %--------------------------------------------------------------------------
        % creates the draw push button
        handles.pbutton_roidraw = uicontrol(handles.panel_drawtools, 'Style', 'PushButton',...
            'Units', 'normalized','Position', [0.03, 0.75, 0.45, 0.2],...
            'String','Draw','Callback',@pbutton_roidraw_callback);

        %--------------------------------------------------------------------------
        % creates the clear push button
        handles.pbutton_roicleardaw = uicontrol(handles.panel_drawtools, 'Style', 'PushButton',...
            'Units', 'normalized','Position', [0.03, 0.5, 0.45, 0.2],...
            'String','Clear','Callback',@pbutton_roicleardaw_callback);

        %--------------------------------------------------------------------------
        % creates the add push button
        handles.pbutton_roiadd = uicontrol(handles.panel_drawtools, 'Style', 'PushButton',...
            'Units', 'normalized','Position', [0.52, 0.75, 0.45, 0.2],...
            'String','Add','Callback',@pbutton_roiadd_callback);

        %--------------------------------------------------------------------------
        % creates the rem push button
        handles.pbutton_roirem = uicontrol(handles.panel_drawtools, 'Style', 'PushButton',...
            'Units', 'normalized','Position', [0.52, 0.5, 0.45, 0.2],...
            'String','Rem','Callback',@pbutton_roirem_callback);

end

guidata(hObject,handles)
