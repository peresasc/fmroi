%% load_paths
funcpath = '/media/andre/data8t/ds000030/funcpath.txt';
funcpath = readcell(funcpath,'Delimiter',[";",'\t']);

confpath = '/media/andre/data8t/ds000030/confpath.txt';
confpath = readcell(confpath,'Delimiter',[";",'\t']);

selconfpath = '/media/andre/data8t/ds000030/selconfpath.txt';
selconfpath = readcell(selconfpath,'Delimiter',[";",'\t']);

%% save_selected_confounds
confsz = zeros(length(confpath),2);
for i = 1:length(confpath)
    curconf = confpath{i};
    [pn,fn,ext] = fileparts(curconf);

    conftable = readtable(curconf,'FileType','delimitedtext');
    conf = table2array(conftable);
    selcols = ~any(isnan(conf));
    conf = conf(:,selcols);
    confsz(i,:) = size(conf);
    writematrix(conf, fullfile(pn,[fn,'_selected.csv']),'Delimiter','tab');
end
disp('DONE!!')

%%
% confpath = selconfpath;
if length(funcpath) ~= length(confpath)
    error(['The number of functional image paths does not match the number of confounds files.', ...
       newline, 'Please ensure that each subject''s functional data has a corresponding confound file.']);
end

subjcmp = zeros(length(funcpath),1);
for i = 1:length(funcpath)
    curfunc = funcpath{i};
    f = strfind(curfunc, '_task-rest_bold');
    a = curfunc(1:f-1);

    curconf = confpath{i};
    c = strfind(curconf, '_task-rest_bold');
    b = curconf(1:c-1);

    subjcmp(i) = strcmpi(a,b);
end
if any(subjcmp == 0)
    error(['Subject ID mismatch between functional images and confound paths.', ...
        newline, 'Please ensure each functional image is paired with the correct confound based on subject ID.']);
else
    disp('Subject IDs in functional images and confounds are properly matched.');
end

% varNames = conftable.Properties.VariableNames;
% 
% gs = contains(varNames, 'global', 'IgnoreCase', true);
% wm = contains(varNames, 'csf', 'IgnoreCase', true);
% csf = contains(varNames, 'white', 'IgnoreCase', true);
% compcor = contains(varNames, 'comp', 'IgnoreCase', true);
% trans = contains(varNames, 'trans', 'IgnoreCase', true);
% rot = contains(varNames, 'rot', 'IgnoreCase', true);
% 
% sel = wm | csf | compcor | trans | rot;
% 
% deriv = contains(varNames, 'derivative', 'IgnoreCase', true);
% sel = sel & ~deriv; 
% 
% selvars = varNames(sel);
% 
% selconf = table2array(conftable(:, selvars));
% writematrix(selconf, 'confounds_selected.csv', 'Delimiter', 'tab');


