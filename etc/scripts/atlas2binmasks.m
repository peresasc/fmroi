function binmasks = atlas2binmasks(mask)

roi_idx = unique(mask(:));
roi_idx(roi_idx==0) = [];

binmasks = cell(length(roi_idx),1);
count = 0;
for i = roi_idx'
    count = count + 1;
    binmasks{count} = mask==i;    
end