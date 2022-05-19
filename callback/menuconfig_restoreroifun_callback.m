function menuconfig_restoreroifun_callback(hObject,~)
% menuconfig_restoreroifun_callback is an internal function of fMROI.
%
% Syntax:
%   menuconfig_restoreroifun_callback(hObject,~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com
handles = guidata(hObject);
roimethdir = fullfile(handles.fmroirootdir,'roimethods');
if exist(roimethdir,'dir')
    rmdir(roimethdir, 's')    
end
mkdir(handles.tpldir);

copyfile(fullfile(handles.fmroirootdir,'etc','default_roimethods'),...
    roimethdir);

addpath(fullfile(roimethdir,'methods'),fullfile(roimethdir,'gui'))
savepath
% Update the popup_roitype
guidata(hObject,handles);
updatepopuproitype(hObject)
