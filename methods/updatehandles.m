function handles = updatehandles(handles)
% updatehandles update the handles variable removing fields that are not
% being used.
%
% Syntax:
%   handles = updatehandles(handles)
%
% Inputs:
%    handles: Structure array to be updated that contains the handles of
%             the components in the GUI.
%
% Outputs:
%    handles: Updated structure array that contains the handles of
%             the components in the GUI.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

fields = fieldnames(handles);

for i = 1:length(fields)
    if isobject(handles.(fields{i}))
        if ~isvalid(handles.(fields{i}))
            handles = rmfield(handles,fields{i});
        end
    end
end

