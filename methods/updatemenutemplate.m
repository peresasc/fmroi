function updatemenutemplate(hObject)
% updatemenutemplate is an internal function of fMROI.
%
% Syntax:
%   updatemenutemplate(hObject)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

handles = guidata(hObject);

%--------------------------------------------------------------------------
% Delete previous Load Template menu
if isfield(handles,'hmenufile_templatecallback')
    for i = 1:length(handles.hmenufile_templatecallback)
        if ishandle(handles.hmenufile_templatecallback(i))
            delete(handles.hmenufile_templatecallback(i))            
        end
    end
end
handles.hmenufile_templatecallback = [];

if isfield(handles,'hmenufile_templates')
    lentpl = length(handles.hmenufile_templates);
    if lentpl > 1
        for j = lentpl:-1:2
            if ishandle(handles.hmenufile_templates(j))
                delete(handles.hmenufile_templates(j))
            end
        end
        handles.hmenufile_templates(2:end) = [];
    end
end

%--------------------------------------------------------------------------
% Generate the new Load Template menu

[~, dn, ~] = dirwalk(handles.tpldir);
pn{1} = handles.tpldir;
auxfn = dir(fullfile(pn{1},'*.nii*'));
if isempty(auxfn)
    fn{1} = [];
else
    for jj = 1:length(auxfn)
        fn{1}{jj} = auxfn(jj).name;
    end
end


for i = 1:length(dn)
    for j = 1:length(dn{i})
        handles.hmenufile_templates(end+1) = uimenu(...
            handles.hmenufile_templates(i), 'Label', dn{i}{j});
        pn{end+1} = fullfile(pn{i},dn{i}{j});
        auxfn = dir(fullfile(pn{end},'*.nii*'));
        if isempty(auxfn)
            fn{end+1} = [];
        else
            for jj = 1:length(auxfn)
                fn{length(pn)}{jj} = auxfn(jj).name;
            end
        end
    end
    
    for k = 1:length(fn{i})
        handles.hmenufile_templatecallback(end+1) = uimenu(...
                handles.hmenufile_templates(i), 'Label', fn{i}{k},...
                'Callback', @menufile_tplopen_callback);        
    end    
end

guidata(hObject,handles);