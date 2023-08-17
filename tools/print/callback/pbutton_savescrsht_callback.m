function pbutton_savescrsht_callback(hObject, ~)
% menutools_getcapture is an internal function for fMROI.
% It captures the selected displayed frame and saves it
% to an image file, either bitmap or jpg
%
% Author: Fer Ponce, 2022
% Last update: Fer Ponce, 23/08/2022, peres.asc@gmail.com

handles = guidata(hObject);

% handles.pbutton_savescrsht
outfilename = get(handles.edit_outscrshtpath,'string');
[pn,fn,ext] = fileparts(outfilename);

% Save the 3 main axes to images
ax_tag = {'axi','cor','sag','vol'};
for i = 1:4
    ax = axes('Parent',handles.panel_graph(i),'Position',[0 0 1 1],...
        'Box','off','Units','normalized','XTick',[],'YTick',[],...
        'color','none');

    f = getframe(ax);
    im = frame2im(f);
    outfn = fullfile(pn,strcat(fn,'_',ax_tag{i},ext));
    imwrite(im,outfn)
    delete(ax);    
end

% Give feedback
% if exist(outfn,'file')
%     fmsg = msgbox("Saved!");
%     pause(3) ;
%     close(fmsg); clear(fmsg);
% end
% 
% a = 1; 