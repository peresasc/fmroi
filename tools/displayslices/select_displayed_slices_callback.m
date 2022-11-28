function select_displayed_slices_callback(h,~)

handles = guidata(h);
slice_idx = handles.slices;
v = handles.view;

path = '/home/proactionlab/Desktop/Fer/Brainfer.nii';
prompt = {'Enter slices to display: '};
dlgtitle = 'Input';
dims = [1 35];
definput = {num2str(slice_idx)};

answer = inputdlg(prompt,dlgtitle,dims,definput);

if ~isempty(answer)
    slice_idx = str2num(answer{1,1});
    handles.slices = slice_idx;
    guidata(h,handles);
    %refresh(h.Parent.Parent)
    menutools_displayslices(h.Parent.Parent,path,slice_idx,v);
end

guidata(h,handles);

a = 1;
%drawnow;
