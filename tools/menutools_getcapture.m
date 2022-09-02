function menutools_getcapture(hObject, ~)
% menutools_getcapture is an internal function for fMROI.
% It captures the selected displayed frame and saves it
% to an image file, either bitmap or jpg
%
% Author: Fer Ponce, 2022
% Last update: Fer Ponce, 23/08/2022, peres.asc@gmail.com

handles = guidata(hObject);

% Ask for a place to store the captures
[fn, pn, idx] = uiputfile({'*.jpg'; '*.bmp';'*.png'},...
    'Save captures');
if idx == 0
    return
end
outfilename = fullfile(pn,fn);
[pn,fn,ext] = fileparts(outfilename);

% Save the 3 main axes to images
ax_tag = {'ax','cor','sag'};
for i = 1:3
    F = getframe(handles.ax{1,i}.ax);
    Image = frame2im(F);
    outName = fullfile(pn,strcat(fn,'_',ax_tag{i},ext));
    imwrite(Image, outName)
end

% Give feedback
if exist(outName,'file')
    f = msgbox("Saved!");
    pause(3) ;
    close(f); clear(f);
end

a = 1; 