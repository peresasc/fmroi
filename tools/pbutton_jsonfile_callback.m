function pbutton_jsonfile_callback(fig,~)
% pbutton_imgup_callback is an internal function of fMROI.
%
% Syntax:
%   pbutton_jsonfile_callback(fig,~)
%
% Inputs:
%   fig: figure that contains the diplayed header.
%
% Author: Fer Ponce, 2022.
% Last update: Fer Ponce, 28/07/2022, peres.asc@gmail.com

hdHeader = guidata(fig);

id = 'MATLAB:printf:BadEscapeSequenceInFormat';
warning('off',id);

namename = hdHeader.ImgTitle;
JSONFILE_name = sprintf('%s_header.json',namename);
hdHeader = guidata(fig);

info_stct = hdHeader.InfoStruct;

[file,path,~] = uiputfile(JSONFILE_name);

% Write JSON file

fid=fopen(JSONFILE_name,'w');
%jsonencode(info, "PrettyPrint", true); %new versions only
encodedJSON = jsonencode(info_stct);
nencoded = strrep(encodedJSON, ',', ',\n');
nencoded = strrep(nencoded, '{', '{\n');
nencoded = strrep(nencoded, '}', '}\n');
fprintf(fid, nencoded);
fclose(fid);

if exist(fullfile(path,file),'file')
    f = msgbox("Done!");
    pause(2)
    if ishandle(f)
        close(f);
    end
    clear('f');
end
