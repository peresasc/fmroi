function axesdrawing_buttondownfcn_callback(hObject,event)

global st
handles = guidata(hObject);
h = getoverobj('type','axes');

if strcmp(event.EventName,'WindowMouseMotion') && handles.mousehold &&...
        ~isempty(h) && not(handles.toolbar) ||...
        strcmp(event.EventName,'Hit')


    listimgdata = get(handles.table_listimg,'Data');
    selaxis = get(handles.popup_workingaxes,'Value'); % select the axis to draw
    ucidx = find(contains(listimgdata(:,3),'roi_under-construction'), 1); % Image selected as template
    wroi = get(handles.popup_workingroi,'Value')-1;
    datalut = get(handles.table_roilut,'Data');

    cp = get(h,'CurrentPoint');
    cp = round(cp(1,1:2));
    mask = handles.ax{ucidx,selaxis}.d.CData;

    r = str2double(get(handles.edit_brushradius,'String'));
    [x,y] = size(mask);
    [My,Mx] = ndgrid(1:x,1:y);
    auxmask = (sqrt((Mx-cp(1)).^2 + (My-cp(2)).^2) < r);

    if handles.mousehold == 1
        
%         mask = mask|auxmask;
%         mask = mask * datalut{wroi,1};
        mask(auxmask) = datalut{wroi,1};
%         mask(cp(2),cp(1)) = datalut{wroi,1};
    else
        mask(auxmask) = 0;
        
%         mask(cp(2),cp(1)) = 0;
    end

    alphavalue = handles.imgprop(ucidx).alpha;
    alpha = zeros(size(mask));
    alpha(logical(mask)) = 1*alphavalue;
    set(handles.ax{ucidx,selaxis}.d)

    set(handles.ax{ucidx,selaxis}.d,'HitTest','off', 'Cdata',mask,'AlphaData',alpha);
end

% %--------------------------------------------------------------------------
% % update current position mousemove
if ~isempty(h)
    n = handles.table_selectedcell(1);
    centre = getworldpos(h);
    cpima = st.vols{n}.mat\[centre';1];
    cpima = round(cpima(1:3))';

    set(handles.text_pos(1),'String',num2str(round(centre)))
    set(handles.text_pos(2),'String',num2str(cpima))

end
% 
% %--------------------------------------------------------------------------
% % add drawn ROI
% wroi = get(handles.popup_workingroi,'Value')-1;
% selaxis = handles.drawingroi.axistag;
% refpos = handles.drawingroi.refpos;
% selimg = handles.drawingroi.selimg;
% 
% mask = handles.ax{selimg,selaxis}.d.CData;
% [row,col] = find(mask);
% planarpos = [col,row];
% 
% listimgdata = getimgnamelist(hObject);
% st.roisrcname = listimgdata{selimg};
% 
% 
% roi = st.roimasks{wroi};
% p = planar2vol(selimg,planarpos,selaxis,refpos);
% i = sub2ind(size(roi),p(:,1),p(:,2),p(:,3));
% 
% maxidx = max(roi(:));
% 
% if maxidx
%     idx = maxidx;
% else
%     idx = 1;
% end
% 
% roi(i) = idx;
% st.roimasks{wroi} = roi;
% 
% 
% guidata(hObject, handles);
% updateroitable(hObject)
% handles = guidata(hObject);
% 
% datalut = get(handles.table_roilut,'Data');
% set(handles.popup_workingroi,'String',[{'new'};datalut(:,2)])
% 
% if wroi
%     set(handles.popup_workingroi,'Value',wroi+1);   
% else
%     set(handles.popup_workingroi,'Value',size(datalut,1)+1);
% end
guidata(hObject, handles);