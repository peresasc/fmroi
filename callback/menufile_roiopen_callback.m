function menufile_roiopen_callback(hObject, ~)
% menufile_roiopen_callback is an internal function of fMROI.
%
% Syntax:
%   menufile_roiopen_callback(hObject, ~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com
global st

menufile_open_callback(hObject)
handles = guidata(hObject);

n = find(~cellfun(@isempty,st.vols), 1, 'last');

guidata(hObject,handles);
listimgdata = getimgnamelist(hObject);
st.roisrcname = listimgdata{n};
mask = uint16(st.vols{n}.private.dat(:,:,:));

%--------------------------------------------------------------------------
% Stores each ROI in a separate matrix in the st structure
roi_idx = unique(mask(:));
roi_idx(roi_idx==0) = [];

datalut = get(handles.table_roilut,'Data');
for i = roi_idx'    
    currmask = mask;
    currmask(currmask~=i) = 0;
    if ~isempty(datalut{1})        
        roiidx = cell2mat(datalut(:,1));
        currmask(logical(currmask)) =...
            currmask(logical(currmask)) + max(roiidx);
        st.roimasks{end+1} = currmask;
    else
        st.roimasks{i} = currmask;
    end
end

guidata(hObject, handles);
updateroitable(hObject)
