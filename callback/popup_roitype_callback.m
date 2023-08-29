function popup_roitype_callback(hObject, ~)
% popup_roitype_callback is an internal function of fMROI.
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
set(handles.pbutton_findmax,'Enable','on')
set(handles.pbutton_roi,'Enable','on')

if isfield(handles,'panel_roimethod')
    if isobject(handles.panel_roimethod)
        if isvalid(handles.panel_roimethod)
            delete(handles.panel_roimethod)
        end
    end
    handles = updatehandles(handles);
end

v = get(handles.popup_roitype,'Value');
s = get(handles.popup_roitype,'String');
roimth = s{v};

fs = dir([handles.roimethdir,filesep,'**',filesep,roimth,'_gui.m']);

if isempty(fs)
    mthguipath = '';
else
    mthguipath = fullfile(fs.folder,fs.name);
end

guidata(hObject, handles)
if isfile(mthguipath)
    feval([roimth,'_gui'],hObject);
    handles = guidata(hObject);
else
    autogen_gui(hObject);
    handles = guidata(hObject);
end

guidata(hObject, handles)