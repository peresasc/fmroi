%%

datarootdir = '/media/andre/data8t/fmroi/tmp/fmroi_qc/dataset/';

datadir = {fullfile(datarootdir,'fmroi-cubicmask');...
           fullfile(datarootdir,'afni-cubicmask');...
           fullfile(datarootdir,'fsl-cubicmask');...
           fullfile(datarootdir,'spm-cubicmask')};


%--------------------------------------------------------------------------
% Defining the input variables: software, roi type, area, volume, etc...
datafolder = cell(length(datadir),1);
for d = 1:length(datadir)

    [~,datafolder{d},~] = fileparts(datadir{d});
    oddoutdir = fullfile(datarootdir,[datafolder{d},'_odd']);
    if ~isfolder(oddoutdir)
        mkdir(oddoutdir)
    end

    roistruc = dir(datadir{d});
    roinames = cell(length(roistruc),1);
    for s = 1:length(roistruc)
        if ~roistruc(s).isdir
            roinames{s} = roistruc(s).name;
        end
    end
    roinames(cellfun(@isempty,roinames)) = [];

    for i = 1:length(roinames)

        edge = str2double(roinames{i}(...
            (strfind(roinames{i},'edge_')+length('edge_')):...
            (strfind(roinames{i},'_center_')-1)));

        if rem(edge,2)
            copyfile(fullfile(datadir{d},roinames{i}),oddoutdir);
        end

    end
    disp([datafolder{d},' --> Done!!'])
end