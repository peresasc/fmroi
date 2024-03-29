function draw_slices(hObject, ~)
% draw_slices is an internal function of fMROI.
%
% Syntax:
%   draw_slices(hObject, ~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

global st
handles = guidata(hObject);

n_image = find(~cellfun(@isempty,st.vols), 1, 'last');

for i = 1:n_image
    slices = getslices(st,i);
    for j = 1:3
        set(handles.ax{i,j}.d,'HitTest','off', 'Cdata',slices{j});
        
        maxthrs = handles.imgprop(i).maxthrs;
        minthrs = handles.imgprop(i).minthrs;
        alphavalue = handles.imgprop(i).alpha;
        
        minthrs = minthrs*(st.vols{i}.clim(2)-st.vols{i}.clim(1))+...
            st.vols{i}.clim(1);
        
        maxthrs = maxthrs*(st.vols{i}.clim(2)-st.vols{i}.clim(1))+...
            st.vols{i}.clim(1);
        
        if minthrs <= maxthrs
            slicemask = slices{j} >= minthrs & slices{j} <= maxthrs;
        else
            slicemask = slices{j} >= minthrs | slices{j} <= maxthrs;
        end
        
        alpha = zeros(size(slices{j}));
        alpha(slicemask)=1*alphavalue;
        set(handles.ax{i,j}.d,'AlphaData',alpha)
        set(handles.ax{i,j}.d,'Visible',handles.imgprop(i).viewslices)
        
        % Update the axial slice in the axes 4 (3D)
        if j == 1
            pos = st.Space\[st.centre,1]'-[st.bb(1,:)-1,1]';
            p3 = pos(3);
            z = p3*ones(size(handles.ax{1,4}.d.ZData));
            handles.ax{i,4}.d.ZData = z;
            c = gettruecolor(slices{j},st.vols{i}.private.dat(:,:,:),handles.ax{i,j}.ax.Colormap);
            handles.ax{i,4}.d.CData = c;
            handles.ax{i,4}.d.AlphaData = handles.ax{i,j}.d.AlphaData;
            handles.ax{i,4}.ax.Colormap = handles.ax{i,j}.ax.Colormap;
            set(handles.ax{i,4}.d, 'FaceAlpha', 'flat','FaceColor',...
                'flat','EdgeColor','none','alphadatamapping','none')
        end
    end
end

bb   = st.bb;
Dims = round(diff(bb)'+1);
is   = inv(st.Space);
cent = is(1:3,1:3)*st.centre(:) + is(1:3,4);


TD = Dims([1 2]);
CD = Dims([1 3]);
if st.mode == 0
    SD = Dims([3 2]);
else
    SD = Dims([2 3]);
end


set(handles.ax{n_image,1}.lx,'HitTest','off',...
    'Xdata',[0 TD(1)]+0.5,'Ydata',[1 1]*(cent(2)-bb(1,2)+1));
set(handles.ax{n_image,1}.ly,'HitTest','off',...
    'Ydata',[0 TD(2)]+0.5,'Xdata',[1 1]*(cent(1)-bb(1,1)+1));

set(handles.ax{n_image,1}.txy,'HitTest','off',...
    'Position', [cent(1)-bb(1,1)+1, cent(2)-bb(1,2)+1]);


set(handles.ax{n_image,2}.lx,'HitTest','off',...
    'Xdata',[0 CD(1)]+0.5,'Ydata',[1 1]*(cent(3)-bb(1,3)+1));
set(handles.ax{n_image,2}.ly,'HitTest','off',...
    'Ydata',[0 CD(2)]+0.5,'Xdata',[1 1]*(cent(1)-bb(1,1)+1));

set(handles.ax{n_image,2}.txy,'HitTest','off',...
    'Position', [cent(1)-bb(1,1)+1, cent(3)-bb(1,3)+1]);

if st.mode == 0
    set(handles.ax{n_image,3}.lx,'HitTest','off',...
        'Xdata',[0 SD(1)]+0.5,'Ydata',[1 1]*(cent(2)-bb(1,2)+1));
    set(handles.ax{n_image,3}.ly,'HitTest','off',...
        'Ydata',[0 SD(2)]+0.5,'Xdata',[1 1]*(cent(3)-bb(1,3)+1));
    
    set(handles.ax{n_image,3}.txy,'HitTest','off',...
    'Position', [cent(3)-bb(1,3)+1, cent(2)-bb(1,2)+1]);
else
    set(handles.ax{n_image,3}.lx,'HitTest','off',...
        'Xdata',[0 SD(1)]+0.5,'Ydata',[1 1]*(cent(3)-bb(1,3)+1));
    set(handles.ax{n_image,3}.ly,'HitTest','off',...
        'Ydata',[0 SD(2)]+0.5,'Xdata',[1 1]*(bb(2,2)+1-cent(2)));
    
    set(handles.ax{n_image,3}.txy,'HitTest','off',...
    'Position', [bb(2,2)+1-cent(2), cent(3)-bb(1,3)+1]);
end
guidata(hObject, handles);
drawnow;

