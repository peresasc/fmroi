%% mricrongl

datadir = '/home/andre/github/tmp/fmroi_qc/dataset/mricrongl-spheremask';
vol = spm_vol('/home/andre/github/tmp/fmroi_qc/dataset/templates/T1.nii.gz');

oldnames = dir([datadir,'/*.nii']);
oldnames = {oldnames(~[oldnames.isdir]).name};

for i = 1:length(oldnames)
    centerstr = oldnames{i}(...
        (strfind(oldnames{i},'center_')+length('center_')):...
        (strfind(oldnames{i},'.nii')-1));

    x = str2double(centerstr((strfind(centerstr,'x')+1):...
        (strfind(centerstr,'y')-1)));
    y = str2double(centerstr((strfind(centerstr,'y')+1):...
        (strfind(centerstr,'z')-1)));
    z = str2double(centerstr((strfind(centerstr,'z')+1):end));
    center = [x;y;z;1];

    cpima = vol.mat\center;
    prefix = oldnames{i}(1:strfind(oldnames{i},centerstr)-1);

    newname = fullfile(datadir,[prefix,'x',sprintf('%03d',cpima(1)),...
        'y',sprintf('%03d',cpima(2)),'z',sprintf('%03d',cpima(3)),'.nii']);

    movefile(fullfile(datadir,oldnames{i}),newname);

end

%% afni_fsl

datadircel = {'/home/andre/github/tmp/fmroi_qc/dataset/afni-cubicmask';...
              '/home/andre/github/tmp/fmroi_qc/dataset/afni-spheremask';...
              '/home/andre/github/tmp/fmroi_qc/dataset/fsl-cubicmask';...
              '/home/andre/github/tmp/fmroi_qc/dataset/fsl-spheremask'};

for d = 1:length(datadircel)
    
    datadir = datadircel{d};
    oldnames = dir([datadir,'/*.nii*']);
    oldnames = {oldnames(~[oldnames.isdir]).name};

    for i = 1:length(oldnames)
        centerstr = oldnames{i}(...
            (strfind(oldnames{i},'center_')+length('center_')):...
            (strfind(oldnames{i},'.nii')-1));

        x = str2double(centerstr((strfind(centerstr,'x')+1):...
            (strfind(centerstr,'y')-1)));
        y = str2double(centerstr((strfind(centerstr,'y')+1):...
            (strfind(centerstr,'z')-1)));
        z = str2double(centerstr((strfind(centerstr,'z')+1):end));

        prefix = oldnames{i}(1:strfind(oldnames{i},centerstr)-1);
        [~,~,ext] = fileparts(oldnames{i});
        newname = fullfile(datadir,[prefix,'x',sprintf('%03d',x+1),...
            'y',sprintf('%03d',y+1),'z',sprintf('%03d',z+1),ext]);

        movefile(fullfile(datadir,oldnames{i}),newname);

    end
end
