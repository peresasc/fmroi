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

[pn, dn, fn] = dirwalk(handles.tpldir);


for i = 1:length(pn)
    h = findobj(handles.hmenufile_templates,'Tag',pn{i});
    for j = 1:length(dn{i})        
        handles.hmenufile_templates(end+1) = uimenu(h(1),'Label', dn{i}{j},...
            'Tag',[h(1).Tag,filesep,dn{i}{j}]);
    end
    fn{i} = fn{i}(contains(fn{i},'.nii'));
    for k = 1:length(fn{i})
        handles.hmenufile_templatecallback(end+1) = uimenu(h(1),...
                'Label',fn{i}{k},'Callback', @menufile_tplopen_callback);        
    end    
end

guidata(hObject,handles);