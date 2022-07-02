function menuconfig_dplres_callback(hObject,~)
% menuconfig_dplres_callback is an internal function of fMROI.
%
% Syntax:
%   menuconfig_dplres_callback(hObject, ~)
%
% Inputs:
%   hObject: handle of the figure that contains the fMROI main window.
%
% Author: Andre Peres, 2019, peres.asc@gmail.com
% Last update: Andre Peres, 09/05/2022, peres.asc@gmail.com

handles = guidata(hObject);
tdata = get(handles.table_listimg,'Data');

if ~isempty(tdata)
    global st

    n = handles.table_selectedcell(1);
    r = get(handles.checkbox_rendering,'Value');
    n_image = find(~cellfun(@isempty,st.vols), 1, 'last');

    if ~isempty(st.bb)

        mn = [Inf Inf Inf];
        mx = -mn;

        premul = st.Space \ st.vols{n}.premul; % A\B == inv(A)*B

        % SPM function to compute volume's bounding box for full field of view.
        bb = spm_get_bbox(st.vols{n}, 'fv', premul);

        mx = max([bb ; mx]);
        mn = min([bb ; mn]);

        st.bb = [mn ; mx];

        % Resolution is set to a isovoxel with edge size equal to the smallest
        % voxel dimension of the first loaded image.
        res = inf;
        res = min([res,sqrt(sum((st.vols{n}.mat(1:3,1:3)).^2))]);
        res = res/mean(svd(st.Space(1:3,1:3)));
        Mat = diag([res res res 1]);

        % Resolution of displayed images. If the images have different
        % resolution they will be transformed to st.Space to be displayed.
        st.Space = st.Space*Mat;

        % Transform st.bb from mm to voxel units, regarding the display voxel
        % resolution st.res.
        st.bb = st.bb/res;

        % Determines the mass center of the displayed image in refrence to the
        % scanner coordinates in mm and stores in the st.centre.
        %     centre_scanner = mean(st.Space*[st.bb';1 1],2)';
        %     st.centre = centre_scanner(1:3);
        st.res = res;
        st.dims = round(diff(st.bb)'+1);
        maxdim = max(round(diff(st.bb)+1));
        cpdpl = st.Space\[st.centre,1]'-[st.bb(1,:)-1,1]';
        for i = 1:n_image
            for j = 1:4
                if j == 4
                    set(handles.ax{i,4}.ax,'Xlim',[0 st.dims(1)],...
                        'Ylim',[0 st.dims(2)],'Zlim',[0 st.dims(3)])
                    [x,y,z] = meshgrid(1:st.dims(1),1:st.dims(2),cpdpl(3));
                    handles.ax{i,4}.d.XData = x;
                    handles.ax{i,4}.d.YData = y;
                    handles.ax{i,4}.d.ZData = z;
                    handles.ax{i,4}.d.CData = zeros(size(z));
                else

                    axis(handles.ax{i,j}.ax,[0 maxdim 0 maxdim])
                    axis(handles.ax{i,j}.ax,'equal')

                end
            end
        end

        guidata(hObject,handles);
        draw_slices(hObject)

        handles = guidata(hObject);

        for i = 1:n_image
            if isfield(handles.ax{i,4},'roipatch')
                if ishandle(handles.ax{i,4}.roipatch)
                    delete(handles.ax{i,4}.roipatch)
                end
                handles.ax{i,4} = rmfield(handles.ax{i,4},'roipatch');
                if handles.imgprop(i).viewrender
                    handles.table_selectedcell(1) = i;
                    set(handles.checkbox_rendering,'Value',1);
                    guidata(hObject,handles)
                    checkbox_rendering_callback(hObject)
                    handles = guidata(hObject);
                end
            end
        end
        handles.table_selectedcell(1) = n;
        set(handles.checkbox_rendering,'Value',r);
    end
    guidata(hObject,handles)
end