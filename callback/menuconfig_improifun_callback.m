function menuconfig_improifun_callback(hObject, ~)
% menuconfig_improifun_callback is an internal function of fMROI.
%
% Syntax:
%   menuconfig_improifun_callback(hObject, ~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

handles = guidata(hObject);

[fn, pn, idx] = uigetfile('*.m','Select one or more m-files',...
    'MultiSelect','on');

if idx
    if ~iscell(fn)
        auxfn = fn;
        clear fn
        fn{1} = auxfn;
    end
    for i = 1:length(fn)
        filename = fullfile(pn,fn{i});
        copyfile(filename,fullfile(handles.fmroirootdir,...
            'roimethods','methods'));
        
        [curpn,curfn,~] = fileparts(filename);
        if isfile(fullfile(curpn,[curfn,'_gui.m'])) &&...
                isfile(fullfile(curpn,[curfn,'_caller.m']))
            
            copyfile(fullfile(curpn,[curfn,'_gui.m']),...
                fullfile(handles.fmroirootdir,'roimethods','gui'));
            
            copyfile(fullfile(curpn,[curfn,'_caller.m']),...
                fullfile(handles.fmroirootdir,'roimethods','gui')); 
        end        
    end
end

guidata(hObject,handles);
updatepopuproitype(hObject)