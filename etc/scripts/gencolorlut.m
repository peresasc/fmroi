function gencolorlut(roinames_path,roiindex_path,savepath)

load(roinames_path);

if isfile(roiindex_path)
    load(roiindex_path);
else
    roi_index = (1:length(roi_names))';    
end

No = roi_index;
Label_Name = roi_names;
R = round(255*rand(length(roi_names),1));
G = round(255*rand(length(roi_names),1));
B = round(255*rand(length(roi_names),1));
A = zeros(length(roi_names),1);

colorlut = table(No, Label_Name, R, G, B, A);

[pn,fn,~] = fileparts(savepath);

save([pn,filesep,fn,'.mat'],'colorlut');

writetable(colorlut,[pn,filesep,fn,'.txt'],...
    'WriteRowNames',true,'Delimiter','tab');

