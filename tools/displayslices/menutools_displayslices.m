function menutools_displayslices(h,path,slice_idx,v)



% .................................................
% section for testing, this should be replaced with fmroi variables for
% images
imgg = niftiread(path);
% .................................................

if ~ishandle(h)
    h = figure('Name','Slices','Color','k','Position',[675 524 800 239]);
    handles = guidata(h);
    slices_menu = uimenu(h,'Text','Options');
    slices_menu.Accelerator = 'F';


    sm_item = uimenu(slices_menu,'Text','Select slices');
    sm_item.MenuSelectedFcn =  @select_displayed_slices_callback;

    sm_item2 = uimenu(slices_menu,'Text','Change view');
    sec_menuS = uimenu(sm_item2,'Text','Sagital');
    sec_menuS.MenuSelectedFcn = @change_slicesview_callback;
    sec_menuC = uimenu(sm_item2,'Text','Coronal');
    sec_menuC.MenuSelectedFcn = @change_slicesview_callback;
    sec_menuA = uimenu(sm_item2,'Text','Axial');
    sec_menuA.MenuSelectedFcn = @change_slicesview_callback;

else
    handles = guidata(h);
end

% modify to get random slices within the image limits 
if ~exist('slice_idx','var')
    slice_idx = [59 79 99 109 119];
elseif isempty(slice_idx)
    slice_idx = [59 79 99 109 119];
end
handles.slices = slice_idx;

if isempty(v)
    v = 2;
end
handles.view = v;
guidata(h,handles);


% Does this make sense?????????????'
slice_idx = handles.slices;
v = handles.view;

cn = 0;

for i = 1:length(slice_idx)
    % subplot(1,length(slice_idx),i)
%     if i == 1
%         idxp = 0;
%     else
%         idxp =1;
%     end
    
    if ~isfield(handles, 'pos')
        %pos = [0+(cn*(0.999/length(slice_idx))) 0.01 (0.989/length(slice_idx)) 1];
        
        perc = (1/length(slice_idx)) * 0.50;
        pos = [0+(cn*(0.999/length(slice_idx))-(perc*cn)) 0.01 (0.989/length(slice_idx)) 1];
    else
        pos = handles.pos;
    end
    
    hax = axes('Position',pos);
    set(hax,'color','none')
    switch v
        case 1 %sagital
            imshow(imrotate(squeeze(imgg(slice_idx(i),:,:)),90),[]);
        case 2
            imshow(imrotate(squeeze(imgg(:,slice_idx(i),:)),90),[]);
            alpha(.5)
        case 3
            imshow(imrotate(squeeze(imgg(:,:,slice_idx(i))),90),[]);
    end
    
    cn = cn + 1;
end

a = 1;