function menutools_showimgheader
% menutools_getimgheader is an internal function for fMROI.
% It displays the NIFTI Header of an image and gives the option
% to save the information to a file.
%
% Syntax:
%   menutools_getimgheader_callback(File)
%
% Inputs:
%   File: Path to image.
%
% Author: Fer Ponce, 2022
% Last update: Fer Ponce, 28/07/2022, peres.asc@gmail.com

% Get image header from the console
prompt= 'File: ';
file = input(prompt,'s');
clc

% Open parent figure
fig_pos = [680  200   560   700];
fig = figure('Name','testuitable','Color','w', ...
    'MenuBar','none','ToolBar','none','NumberTitle','off',...
    'DockControls','off','Render','opengl',...
    'Units','Pixels','Position',fig_pos);
hdHeader = guidata(fig);

info = niftiinfo(file);

% Get individual name
fdrDiv = strfind(info.Filename,'/');
hdHeader.ImgTitle = info.Filename(fdrDiv(end)+1:end-4);

% Prepare data structure to display the header
info_table = struct2table(info, 'AsArray', true);
info_table = removevars(info_table, 'raw');
info_table = splitvars(info_table);
info_table= rows2vars(info_table);

auxtb = table2cell(info_table);

trfmrw = (find(strcmp(auxtb, 'Transform')));
if ~isempty(trfmrw)
    auxtb(trfmrw,:) = [];
end

auxtb(1,1) = {'File'};

for i = 1:length(auxtb)
    classOpt = ['int8','int16','int32','int64',...
        'uint8','uint16','uint32','uint64','double'];
    %is_dbl = strfind(classOpt,class(auxtb{i,2}));
    if contains(classOpt,class(auxtb{i,2}))
        auxtb{i,2} = int2str(auxtb{i,2});
    end
end

hdHeader.InfoStruct = info;
hdHeader.InfoTable = info_table;

% Display header
tbpos = [0.04 0.1 .93 .88];
uit = uitable(fig,'Data',auxtb,'Units','normalized',...
        'ColumnName', ["Field","Info"],'Position', tbpos,...
        'ColumnEditable', [false false],...
        'BackgroundColor',[1 1 1],'ColumnWidth',{212,271});
    % The original pizel size is 560 (width) for when we open or display
    % a figure, as specified. So I distributed those pixels almost evenly.

% Creates push button for saving as json file
hdHeader.pbuttonjsonfile.obj = uicontrol(fig, 'Style', 'PushButton',...
    'Units', 'normalized','Position', [0.24, 0.019, 0.19, 0.06],...
    'String','Save as json','Callback',@pbutton_jsonfile_callback);
hdHeader.pbuttoncross.action = 1;
% 'ForeGroundexzxColor',[1 0 0],

% % Creates push button for saving as txt file
hdHeader.pbuttontxtfile.obj = uicontrol(fig, 'Style', 'PushButton',...
    'Units', 'normalized','Position', [0.59, 0.019, 0.19, 0.06],...
    'String','Save as txt','Callback',@pbutton_txtfile_callback);
hdHeader.pbuttoncross.action = 1;

guidata(fig,hdHeader);


