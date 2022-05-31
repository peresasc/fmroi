function disallowRotation = rotatefilter_callback(obj,~)

disallowRotation = true;
% hManager = uigetmodemanager(gcf);
% try
%     set(hManager.WindowListenerHandles, 'Enable', 'off');  % HG1
% catch
%     [hManager.WindowListenerHandles.Enabled] = deal(false);  % HG2
% end

tag = get(obj,'Tag');
tag = tag(1:9);
 % if a ButtonDownFcn has been defined for the object, then use that
%  if isfield(get(obj),'ButtonDownFcn')
if strcmpi(tag,'rendering')
    %      disallowRotation = ~isempty(get(obj,'ButtonDownFcn'));
    disallowRotation = false;
    
%     hManager = uigetmodemanager(gcf);
%     try
%         set(hManager.WindowListenerHandles, 'Enable', 'on');  % HG1
%     catch
%         [hManager.WindowListenerHandles.Enabled] = deal(true);  % HG2
%     end
end