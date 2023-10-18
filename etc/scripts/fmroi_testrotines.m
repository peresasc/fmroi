%==========================================================================
%% spheremask_cubicmask
%==========================================================================

for w = 1:2 % strategy for running spheremask and cubicmask separately
    clearvars -except w
    close all

%--------------------------------------------------------------------------
% input dataset paths
    datarootdir = '/media/andre/data8t/fmroi/tmp/fmroi_qc/dataset/';
    if w == 1
        datadir = {fullfile(datarootdir,'fmroi-spheremask');...
                   fullfile(datarootdir,'afni-spheremask');...
                   fullfile(datarootdir,'fsl-spheremask');...
                   fullfile(datarootdir,'spm-spheremask');...
                   fullfile(datarootdir,'mricrongl-spheremask')};
    else
        datadir = {fullfile(datarootdir,'fmroi-cubicmask');...
                   fullfile(datarootdir,'afni-cubicmask');...
                   fullfile(datarootdir,'fsl-cubicmask');...
                   fullfile(datarootdir,'spm-cubicmask')};
    end

%--------------------------------------------------------------------------
% create the output folders
    rootoutdir = '/home/andre/github/tmp/fmroi_qc';
    figoutdir = fullfile(rootoutdir,'figures');
    if ~isfolder(figoutdir)
        mkdir(figoutdir)
    end

    tboutdir = fullfile(rootoutdir,'statstable');
    if ~isfolder(tboutdir)
        mkdir(tboutdir)
    end

    tbextradir = fullfile(tboutdir,'extra');
    if ~isfolder(tbextradir)
        mkdir(tbextradir)
    end

    mdloutdir = fullfile(rootoutdir,'models');
    if ~isfolder(mdloutdir)
        mkdir(mdloutdir)
    end

%--------------------------------------------------------------------------
% Defining the input variables: software, roi type, area, volume, etc...
    datafolder = cell(length(datadir),1);
    Algorithm = cell(length(datadir),1); % Software used for creating ROIs
    roitype = cell(length(datadir),1); % type of the ROI (spherical or cubic)
    mdlav = cell(length(datadir),1); % model of the ROI area/volume
    mdla = cell(length(datadir),1); % model of the ROI area
    mdlv = cell(length(datadir),1); % model of the ROI volume
    mdlc = cell(length(datadir),3); % model of the ROI center
    for d = 1:length(datadir)
        [~,datafolder{d},~] = fileparts(datadir{d});
        Algorithm{d} = datafolder{d}(1:strfind(datafolder{d},'-')-1);
        roitype{d} = datafolder{d}(strfind(datafolder{d},'-')+1:end);
        roistruc = dir(datadir{d});
        roinames = cell(length(roistruc),1);
        for s = 1:length(roistruc)
            if ~roistruc(s).isdir
                roinames{s} = roistruc(s).name;
            end
        end
        roinames(cellfun(@isempty,roinames)) = [];

        radius = zeros(length(roinames),1);
        center = zeros(length(roinames),3);
        masscenter = zeros(length(roinames),3);
        area = zeros(length(roinames),1);
        vol = zeros(length(roinames),1);
        for i = 1:length(roinames)
            disp(['Working on ',datafolder{d},' ROI ',num2str(i)]);

            switch roitype{d}
                case 'spheremask'
                    radius(i) = str2double(roinames{i}(...
                        (strfind(roinames{i},'radius_')+length('radius_')):...
                        (strfind(roinames{i},'_center_')-1)));

                otherwise %case 'cubicmask'
                    radius(i) = str2double(roinames{i}(...
                        (strfind(roinames{i},'edge_')+length('edge_')):...
                        (strfind(roinames{i},'_center_')-1)));
            end

            centerstr = roinames{i}(...
                (strfind(roinames{i},'center_')+length('center_')):...
                (strfind(roinames{i},'.nii')-1));

            x = str2double(centerstr((strfind(centerstr,'x')+1):...
                (strfind(centerstr,'y')-1)));
            y = str2double(centerstr((strfind(centerstr,'y')+1):...
                (strfind(centerstr,'z')-1)));
            z = str2double(centerstr((strfind(centerstr,'z')+1):end));
            center(i,:) = [x,y,z];

%--------------------------------------------------------------------------
% Loads ROI and defines the ROI voxels coordinates, area, and volume
            vroi = spm_vol(fullfile(datadir{d},roinames{i}));
            roi = spm_data_read(vroi);
            [x1,y1,z1] = find3d(roi);
            masscenter(i,:) = mean([x1,y1,z1],1);

            [a,v,~,~] = roi_areavol(roi); % function roi_areavol is at fmroirootfolder/etc/scripts
            area(i) = a;
            vol(i) = v;
        end

%--------------------------------------------------------------------------
% calculate theoretical values of area and volume
        switch roitype{d}
            case 'spheremask'
                ta = 4*pi()*(radius).^2; % theoretical sphere area
                tv = 4/3*pi()*(radius).^3; % theoretical sphere volume
                tav = 3./radius; % theoretical sphere area/volume

            otherwise %case 'cubicmask'
                ta = 6*(radius).^2; % theoretical cube area
                tv = (radius).^3; % theoretical cube volume
                tav = 6./radius; % theoretical cube area/volume
        end
        mav = area./vol; % measured area/volume

        close all

%--------------------------------------------------------------------------
% performs linear regression of measured and theoretical values
       
        % Linear regression of Area/Volume
        mdlav{d} = fitlm(tav,mav);
        hfigav = figure('Position',[675,549,300,280]);
        hptav = plot(tav,mav,'k.');
        hold on
        hmdlav = plot(mdlav{d});
        h45av = line([0 max(tav)],[0 max(tav)],'Color',[.6,.6,.6],...
            'LineStyle','--');
        hmdlav(2).LineStyle = ':';
        delete(hmdlav(1))
        delete(hmdlav(3))
        delete(hmdlav(4))
        title(datafolder{d},'FontSize',16)
        xlabel('Theoretical Area/Volume','FontSize',12)
        ylabel('Observed Area/Volume','FontSize',12)
        legend('Data','Linear Fit','Expected fit','Location','southeast')
        ha1 = annotation('textbox', [0.15, 0.85, 0.75, 0.05],...
            'String', ['Y = ', num2str(mdlav{d}.Coefficients{1,1}),...
            ' + X*',num2str(mdlav{d}.Coefficients{2,1})],...
            'EdgeColor','none','Interpreter', 'none');

        mdl = mdlav{d};
        currnrmse = (sqrt(mean((mdl.Variables.x1-mdl.Variables.y).^2)))...
                    /mean(mdl.Variables.y); % vector for the current model
        ha2 = annotation('textbox', [0.15, 0.8, 0.75, 0.05],...
            'String', ['NRMSE = ', num2str(currnrmse)],...
            'EdgeColor','none','Interpreter', 'none');
        hold off

        save([mdloutdir,filesep,datafolder{d},'_fitlm-areavol.mat'],'mdl');
        saveas(hfigav,[figoutdir,filesep,datafolder{d},...
            '_fitlm-areavol.png'])
        clear mdl currnrmse

        % Linear regression of Area
        mdla{d} = fitlm(ta,area);
        hfiga = figure('Position',[675,549,300,280]);
        hpta = plot(ta,area,'k.');
        hold on
        hmdla = plot(mdla{d});
        h45a = line([0 max(ta)],[0 max(ta)],'Color',[.6,.6,.6],...
            'LineStyle','--');
        hmdla(2).LineStyle = ':';
        delete(hmdla(1))
        delete(hmdla(3))
        delete(hmdla(4))
        title(datafolder{d},'FontSize',16)
        xlabel('Theoretical Area','FontSize',12)
        ylabel('Observed Area','FontSize',12)
        legend('Data','Linear Fit','Expected fit','Location','southeast')
        ha1 = annotation('textbox', [0.15, 0.85, 0.75, 0.05],...
            'String', ['Y = ', num2str(mdla{d}.Coefficients{2,1}),...
            ' + X*',num2str(mdla{d}.Coefficients{2,1})],...
            'EdgeColor','none','Interpreter', 'none');
        
        mdl = mdla{d};
        currnrmse = (sqrt(mean((mdl.Variables.x1-mdl.Variables.y).^2)))...
                    /mean(mdl.Variables.y); % vector for the current model
        ha2 = annotation('textbox', [0.15, 0.8, 0.75, 0.05],...
            'String', ['NRMSE = ', num2str(currnrmse)],...
            'EdgeColor','none','Interpreter', 'none');
        hold off
        
        save([mdloutdir,filesep,datafolder{d},'_fitlm-area.mat'],'mdl');
        saveas(hfiga,[figoutdir,filesep,datafolder{d},'_fitlm-area.png'])
        clear mdl currnrmse

        % Linear regression of Volume
        mdlv{d} = fitlm(tv,vol);
        hfigv = figure('Position',[675,549,300,280]);
        hptv = plot(tv,vol,'k.');
        hold on
        hmdlv = plot(mdlv{d});
        h45v = line([0 max(tv)],[0 max(tv)],'Color',[.6,.6,.6],...
            'LineStyle','--');
        hmdlv(2).LineStyle = ':';
        delete(hmdlv(1))
        delete(hmdlv(3))
        delete(hmdlv(4))
        title(datafolder{d},'FontSize',16)
        xlabel('Theoretical Volume','FontSize',12)
        ylabel('Observed Volume','FontSize',12)
        legend('Data','Linear Fit','Expected fit','Location','southeast')
        ha1 = annotation('textbox', [0.15, 0.85, 0.75, 0.05],...
            'String', ['Y = ', num2str(mdlv{d}.Coefficients{1,1}),...
            ' + X*',num2str(mdlv{d}.Coefficients{2,1})],...
            'EdgeColor','none','Interpreter', 'none');
        
        mdl = mdlv{d};
        currnrmse = (sqrt(mean((mdl.Variables.x1-mdl.Variables.y).^2)))...
                    /mean(mdl.Variables.y); % vector for the current model
        ha2 = annotation('textbox', [0.15, 0.8, 0.75, 0.05],...
            'String', ['NRMSE = ', num2str(currnrmse)],...
            'EdgeColor','none','Interpreter', 'none');
        hold off
         
        save([mdloutdir,filesep,datafolder{d},'_fitlm-vol.mat'],'mdl');
        saveas(hfigv,[figoutdir,filesep,datafolder{d},'_fitlm-vol.png'])
        clear mdl

        % Linear regression of Center (x,y,z)
        for i = 1:3 % calculates the displacement for x, y, and z separately
            mdlc{d,i} = fitlm(center(:,i),masscenter(:,i));
            hfigc = figure('Position',[675,549,300,280]);
            hptc = plot(center(:,i),masscenter(:,i),'k.');
            hold on
            hmdlc = plot(mdlc{d,i});
            h45c = line([0 max(center(:,i))],[0 max(center(:,i))],...
                'Color',[.6,.6,.6],'LineStyle','--');
            hmdlc(2).LineStyle = ':';
            delete(hmdlc(1))
            delete(hmdlc(3))
            delete(hmdlc(4))
            ax = 'xyz';
            title(datafolder{d},'FontSize',16)
            xlabel(['Set ',ax(i),' center'],'FontSize',12)
            ylabel([ax(i),' mass center'],'FontSize',12)
            legend('Data','Linear Fit','Expected fit',...
                'Location','southeast')
            ha1 = annotation('textbox', [0.15, 0.85, 0.75, 0.05],...
                'String', ['Y = ', num2str(mdlc{d,i}.Coefficients{1,1}),...
                ' + X*',num2str(mdlc{d,i}.Coefficients{2,1})],...
                'EdgeColor','none','Interpreter', 'none');
            
            mdl = mdlc{d,i};
            currnrmse = (sqrt(mean((mdl.Variables.x1-mdl.Variables.y).^2)))...
                    /mean(mdl.Variables.y); % vector for the current model
            ha2 = annotation('textbox', [0.15, 0.8, 0.75, 0.05],...
            'String', ['NRMSE = ', num2str(currnrmse)],...
            'EdgeColor','none','Interpreter', 'none');
            hold off
            
            save([mdloutdir,filesep,datafolder{d},...
                '_fitlm-center_',ax(i),'.mat'],'mdl');
            saveas(hfigc,[figoutdir,filesep,datafolder{d},...
                '_fitlm-center_',ax(i),'.png'])
            clear mdl currnrmse
        end
    end
    
%--------------------------------------------------------------------------
% Calculates the stats
    models = {'mdlav';'mdla';'mdlv';'mdlc'};
    nrmse_mat = zeros(length(datadir),length(models));
    for m = 1:length(models)
        clear mdl
        mdl = eval(models{m});
        
        NRMSE = zeros(size(mdl,1),1);        
        Pearson_R = zeros(size(mdl,1),1);
        Alpha = zeros(size(mdl,1),1);
        Intercept = zeros(size(mdl,1),1);
        DoF = zeros(size(mdl,1),1);
        R2 = zeros(size(mdl,1),1);
        pValue = zeros(size(mdl,1),1);
        StdError = zeros(size(mdl,1),1);
        RMSE_fit = zeros(size(mdl,1),1);
        for dd = 1:size(mdl,2) % model dimension (e.g. area = 1; center = 3 [x, y, z])
            for d = 1:size(mdl,1) % number of datasets (e.g. fmroi,fsl,etc...)
                if dd == 1 % As "center" has 3 dimensions this block prevines creating a NRMSE for each dimension
                    x = [];
                    y = [];
                    for ddd = 1:size(mdl,2) % concatenates all dimensions and returns only one NRMSE
                        x = [x; mdl{d,ddd}.Variables.x1];
                        y = [y; mdl{d,ddd}.Variables.y];
                    end
                    NRMSE(d) = (sqrt(mean((x-y).^2)))/mean(y); % vector for the current model
                    nrmse_mat(d,m) = NRMSE(d); % table for all models ('mdlav';'mdla';'mdlv';'mdlc')
                end
                pc = corrcoef(mdl{d,dd}.Variables.x1,mdl{d,dd}.Variables.y);
                Pearson_R(d) = pc(2);
                Alpha(d) = mdl{d,dd}.Coefficients{2,1};
                Intercept(d) = mdl{d,dd}.Coefficients{1,1};
                DoF(d) = mdl{d,dd}.DFE;
                R2(d) = mdl{d,dd}.Rsquared.Ordinary;
                pValue(d) = mdl{d,dd}.Coefficients{2,4};
                StdError(d) = mdl{d,dd}.Coefficients{2,2};
                RMSE_fit(d) = mdl{d,dd}.RMSE;
            end
            
%--------------------------------------------------------------------------
% Creates the stats table
            if size(mdl,2) == 1
                tb = table(Algorithm,NRMSE,Pearson_R,Alpha,...
                    Intercept,DoF,R2,pValue,StdError,RMSE_fit);
            else
                if dd == 1
                    tb = table(Algorithm,NRMSE,Pearson_R,Alpha,Intercept,...
                        DoF,R2,pValue,StdError,RMSE_fit,'VariableNames',...
                        {'Algorithm','NRMSE',...
                        ['Pearson_R_dim',num2str(dd)],['Alpha_dim',num2str(dd)],...
                        ['Intercept_dim',num2str(dd)],['DoF_dim',num2str(dd)],...
                        ['R2_dim',num2str(dd)],['pValue_dim',num2str(dd)],...
                        ['StdError_dim',num2str(dd)],['RMSE_fit_dim',num2str(dd)]});

                else
                    auxtb = table(Pearson_R,Alpha,Intercept,...
                        DoF,R2,pValue,StdError,RMSE_fit,'VariableNames',...
                        {['Pearson_R_dim',num2str(dd)],['Alpha_dim',num2str(dd)],...
                        ['Intercept_dim',num2str(dd)],['DoF_dim',num2str(dd)],...
                        ['R2_dim',num2str(dd)],['pValue_dim',num2str(dd)],...
                        ['StdError_dim',num2str(dd)],['RMSE_fit_dim',num2str(dd)]});

                    tb = [tb,auxtb];
                end
            end
        end
%--------------------------------------------------------------------------
% Saves the stats table in a csv file        
        writetable(tb,[tbextradir,filesep,roitype{1},'_',models{m},'.csv']);
    end
    varnames = [{'Algorithm'}; models];
    nrmse_tb = table(Algorithm,nrmse_mat(:,1),nrmse_mat(:,2),...
        nrmse_mat(:,3),nrmse_mat(:,4),'VariableNames',varnames);
    writetable(nrmse_tb,[tboutdir,filesep,roitype{1},'_nrmse.csv']);
end

%==========================================================================
%% image2mask
%==========================================================================
clear
close all

%--------------------------------------------------------------------------
% input dataset paths
datadir = {'/home/andre/github/tmp/fmroi_qc/dataset/fmroi-img2mask'};
%     '/home/andre/github/tmp/fmroi_qc/dataset/afni-img2mask';...
%     '/home/andre/MRIcroGL/mystuff/mricrogl-img2mask';...
%            '/home/andre/github/tmp/fmroi_qc/dataset/afni-img2mask';...
%            '/home/andre/github/tmp/fmroi_qc/dataset/spm-img2mask'};

%--------------------------------------------------------------------------
% create the output folders
rootoutdir = '/home/andre/github/tmp/fmroi_qc';
tboutdir = fullfile(rootoutdir,'statstable');
if ~isfolder(tboutdir)
    mkdir(tboutdir)
end

fmroirootdir = '/home/andre/github/fmroi';
srcpath_dmn = fullfile(fmroirootdir,'templates',...
    'Neurosynth','default_mode_association-test_z_FDR_0.01.nii.gz');
vsrc_dmn = spm_vol(srcpath_dmn);
srcvol_dmn = spm_data_read(vsrc_dmn);

srcpath_syn = fullfile(fmroirootdir,'templates',...
    'syndata','complex-shapes.nii.gz');
vsrc_syn = spm_vol(srcpath_syn);
srcvol_syn = spm_data_read(vsrc_syn);

%--------------------------------------------------------------------------
% Extracts the input/output variables: ROI algorithm, ROI type, precision, etc...
datafolder = cell(length(datadir),1);
algorithm = cell(length(datadir),1); % Software used for creating ROIs
roitype = cell(length(datadir),1); % Type of ROI 
precision = zeros(length(datadir),1); % Precision
recall = zeros(length(datadir),1); % Recall
f1 = zeros(length(datadir),1); % f1-score
for d = 1:length(datadir) % loop for all evaluated ROI algorithms
    [~,datafolder{d},~] = fileparts(datadir{d});
    algorithm{d} = datafolder{d}(1:strfind(datafolder{d},'-')-1);
    roitype{d} = datafolder{d}(strfind(datafolder{d},'-')+1:end);
    roistruc = dir(datadir{d});
    roinames = cell(length(roistruc),1);
    for s = 1:length(roistruc)
        if ~roistruc(s).isdir
            roinames{s} = roistruc(s).name;
        end
    end
    roinames(cellfun(@isempty,roinames)) = [];
    
    tp = zeros(length(roinames),1);
    prec = zeros(length(roinames),1);
    rec = zeros(length(roinames),1);

    for i = 1:length(roinames)
        disp(['Working on ',datafolder{d},' ROI ',num2str(i)]);

    %----------------------------------------------------------------------
    % Loads the template image (DMN or syndata) and thresholds
        srcvolstr = roinames{i}(...
            (strfind(roinames{i},'srcimg_')+length('srcimg_')):...
            (strfind(roinames{i},'_threshold_')-1));
        switch srcvolstr 
            case 'dmn'
                srcvol = srcvol_dmn;
            case 'syndata'
                srcvol = srcvol_syn;
        end
        
        thrstr = roinames{i}(...
            (strfind(roinames{i},'threshold_')+length('threshold_')):...
            (strfind(roinames{i},'.nii')-1));

        minthr = str2double(thrstr(1:strfind(thrstr,'_')-1));
        maxthr = str2double(thrstr(strfind(thrstr,'_')+1:end));
        
%--------------------------------------------------------------------------
% Defines the template ROI voxels coordinates
        if minthr <= maxthr
            tplpos = find(srcvol>=minthr & srcvol<=maxthr);
        else
            tplpos = find(srcvol>=minthr | srcvol<=maxthr);
        end
%--------------------------------------------------------------------------
% Loads ROI and defines the ROI voxels coordinates
        vroi = spm_vol(fullfile(datadir{d},roinames{i}));
        roi = spm_data_read(vroi);
        roipos = find(roi);

%--------------------------------------------------------------------------
% Compares the voxels coordinates from template and ROI to-be-tested
        if isempty(roipos) || isempty(tplpos) % strategy to avoid division by zero
            if isempty(roipos) && isempty(tplpos) % if both, template and measured data a empty so precision = 1
                prec(i) = 1; % precision
                rec(i) = 1; % recall
            else % if template and measured data have different number of elements precision = 0
                prec(i) = 0; % precision
                rec(i) = 0; % recall
            end
        else
            tp(i) = sum(ismember(roipos,tplpos)); % check how many elemets of measured roi are in the same position as the template roi
            prec(i) = tp(i)/length(roipos); % precision
            rec(i) = tp(i)/length(tplpos); % recall
        end
    end
    precision(d) = mean(prec); % averge precision
    recall(d) = mean(rec); % averge recall
    f1(d) = 2*precision(d)*recall(d)/(precision(d)+recall(d)); % average f1-score
end

%--------------------------------------------------------------------------
% Saves the results in a csv file
tb = table(algorithm,precision,recall,f1);
writetable(tb,[tboutdir,filesep,roitype{1},'.csv']);


%==========================================================================
%% clustermask
%==========================================================================
clear
close all
%--------------------------------------------------------------------------
% input dataset paths
datadir = {'/home/andre/github/tmp/fmroi_qc/dataset/fmroi-clustermask'};
           % '/home/andre/github/tmp/fmroi_qc/dataset/afni-clustermask'};

%--------------------------------------------------------------------------
% Loads template images
fmroirootdir = '/home/andre/github/fmroi';
srcpath = fullfile(fmroirootdir,'templates',...
    'syndata','64-spheres.nii.gz');

vsrc = spm_vol(srcpath);
srcvol = spm_data_read(vsrc);

szpath = fullfile(fmroirootdir,'templates',...
    'syndata','64-spheres_size.nii.gz');
vsz = spm_vol(szpath);
szvol = spm_data_read(vsz);

sz = unique(szvol);
sz(sz==0) = [];

%--------------------------------------------------------------------------
% create the output folders
rootoutdir = '/home/andre/github/tmp/fmroi_qc';
tboutdir = fullfile(rootoutdir,'statstable');
if ~isfolder(tboutdir)
    mkdir(tboutdir)
end

%--------------------------------------------------------------------------
% Extracts the input/output variables: ROI algorithm, ROI type, precision, etc...
datafolder = cell(length(datadir),1);
algorithm = cell(length(datadir),1);
roitype = cell(length(datadir),1);
precision = zeros(length(datadir),1);
recall = zeros(length(datadir),1);
f1 = zeros(length(datadir),1);
for d = 1:length(datadir) % loop for each dataset
    [~,datafolder{d},~] = fileparts(datadir{d});
    algorithm{d} = datafolder{d}(1:strfind(datafolder{d},'-')-1);
    roitype{d} = datafolder{d}(strfind(datafolder{d},'-')+1:end);
    roistruc = dir(datadir{d});
    roinames = cell(length(roistruc),1);
    for s = 1:length(roistruc)
        if ~roistruc(s).isdir
            roinames{s} = roistruc(s).name;
        end
    end
    roinames(cellfun(@isempty,roinames)) = [];

    roiprefix = roinames;
    for n = 1:length(roiprefix)
        roiprefix{n}(strfind(roiprefix{n},'_cluster'):end) = [];
    end

    roiprefix = unique(roiprefix);
    tp = zeros(length(roinames),1);
    prec = zeros(length(roinames),1);
    rec = zeros(length(roinames),1);
    c = 0;
    for t = 1:length(roiprefix) % loop for each set of parameters (srcimg, threshold, mincsz)
        fnidx = find(~cellfun(@isempty,strfind(roinames,roiprefix{t})));
        thrstr = roiprefix{t}(...
            (strfind(roiprefix{t},'threshold_')+length('threshold_')):...
            (strfind(roiprefix{t},'_mincsz')-1));

        minthr = str2double(thrstr(1:strfind(thrstr,'_')-1));
        maxthr = str2double(thrstr(strfind(thrstr,'_')+1:end));

        mincsz = str2double(roiprefix{t}(...
            (strfind(roiprefix{t},'_mincsz_')+length('_mincsz_')):end));

%--------------------------------------------------------------------------
% Creates the template ROI
        filtvol = srcvol;
        filtvol(szvol<mincsz) = 0; % delete all ROIs smaller than mincsz
        filtvol(~(srcvol>=minthr & srcvol<=maxthr)) = 0; % delete ROIs with values lower than minthr and higher than maxthr
        
%--------------------------------------------------------------------------
% Load ROIs to-be-tested 
        tplpos_all = [];
        for i = 1:length(fnidx) % loop for all ROIs generated by each parameters set
            c = c + 1;
            disp(['Working on ',datafolder{d},' ROI ',num2str(c)]);

            vroi = spm_vol(fullfile(datadir{d},roinames{fnidx(i)}));
            roi = spm_data_read(vroi);
            roipos = find(roi); % Defines the ROI to-be-tested voxels coordinates

%--------------------------------------------------------------------------
% Compares the voxels coordinates from template and ROI to-be-tested       
            tplpos = find(filtvol==median(srcvol(roipos))); % Defines the template ROI voxels coordinates      
            tplpos_all = [tplpos_all;tplpos]; % vector with all non-zero voxels
            if isempty(roipos) || isempty(tplpos) % strategy to avoid division by zero
                if isempty(roipos) && isempty(tplpos) % if both, template and measured data a empty so precision = 1
                    prec(c) = 1; % precision
                    rec(c) = 1; % recall
                else % if template and measured data have different number of elements precision = 0
                    prec(c) = 0; % precisions
                    rec(c) = 0; % recall
                end
            else
                tp(c) = sum(ismember(roipos,tplpos)); % check how many elemets of measured roi are in the same position as the template roi
                prec(c) = tp(c)/length(roipos); % precision
                rec(c) = tp(c)/length(tplpos); % recall
            end
        end

%--------------------------------------------------------------------------
% Test if there is some ROI missing
        filtvol(tplpos_all) = 0;
        missingroi = unique(filtvol);
        nmiss = numel(find(missingroi));
        prec = [prec; zeros(nmiss,1)]; % adds a precision equal zero for every missing roi
        rec = [rec; zeros(nmiss,1)]; % adds a recall equal zero for every missing roi
    end

%--------------------------------------------------------------------------
% Calculates the average precision, recall, and f1-score    
    precision(d) = mean(prec);
    recall(d) = mean(rec);
    f1(d) = 2*precision(d)*recall(d)/(precision(d)+recall(d));
end

%--------------------------------------------------------------------------
% Saves the results in a csv file
tb = table(algorithm,precision,recall,f1);
writetable(tb,[tboutdir,filesep,roitype{1},'_spheres.csv']);

%==========================================================================
%% maxkmask
%==========================================================================
clear
close all

%--------------------------------------------------------------------------
% input dataset paths
datadir = {'/home/andre/github/tmp/fmroi_qc/dataset/fmroi-maxkmask'};

%--------------------------------------------------------------------------
% Template dataset paths
fmroirootdir = '/home/andre/github/fmroi';
srcpath = fullfile(fmroirootdir,'etc','test_data',...
    'default_mode_association-test_z_FDR_0.01_gaussnoise_5db.nii.gz');
vsrc = spm_vol(srcpath);
srcvol = spm_data_read(vsrc);

prepath = fullfile(fmroirootdir,'templates',...
    'FreeSurfer','cvs_avg35_inMNI152','aparc+aseg_2mm.nii.gz');
vpre = spm_vol(prepath);
prevol = spm_data_read(vpre);

%--------------------------------------------------------------------------
% create the output folders
rootoutdir = '/home/andre/github/tmp/fmroi_qc';
tboutdir = fullfile(rootoutdir,'statstable');
if ~isfolder(tboutdir)
    mkdir(tboutdir)
end

%--------------------------------------------------------------------------
% Extracts the input/output variables: ROI algorithm, ROI type, precision, etc...
datafolder = cell(length(datadir),1);
algorithm = cell(length(datadir),1);
roitype = cell(length(datadir),1);
precision = zeros(length(datadir),1);
recall = zeros(length(datadir),1);
f1 = zeros(length(datadir),1);
for d = 1:length(datadir)
    [~,datafolder{d},~] = fileparts(datadir{d});
    algorithm{d} = datafolder{d}(1:strfind(datafolder{d},'-')-1);
    roitype{d} = datafolder{d}(strfind(datafolder{d},'-')+1:end);
    roistruc = dir(datadir{d});
    roinames = cell(length(roistruc),1);
    for s = 1:length(roistruc)
        if ~roistruc(s).isdir
            roinames{s} = roistruc(s).name;
        end
    end
    roinames(cellfun(@isempty,roinames)) = [];
    
    tp = zeros(length(roinames),1); % true positives
    prec = zeros(length(roinames),1); % precision
    rec = zeros(length(roinames),1); % recall
    for i = 1:length(roinames)
        disp(['Working on ',datafolder{d},' ROI ',num2str(i)]);
        
        % premask index
        pmidx = str2double(roinames{i}(...
            (strfind(roinames{i},'premaskidx_')+length('premaskidx_')):...
            (strfind(roinames{i},'_kvox')-1)));
        
        % ROI size (k voxels)
        kvox = str2double(roinames{i}(...
            (strfind(roinames{i},'kvox_')+length('kvox_')):...
            (strfind(roinames{i},'.nii')-1)));
        
%--------------------------------------------------------------------------
% Defines the template ROI voxels coordinates        
        premask = prevol == pmidx; % defines the premask
        pmpos = find(premask); % finds all voxels coordinates into premask
        srctpl = srcvol(pmpos); % extracts srcvol voxels in the same coordinates as premask
        [~, srctplpos] = maxk(srctpl(:),kvox); % finds the highest k voxels into srctpl
        tplpos = pmpos(srctplpos); % finds the coordinates of the k highest voxels

%--------------------------------------------------------------------------
% Loads ROI and defines the ROI voxels coordinates     
        vroi = spm_vol(fullfile(datadir{d},roinames{i}));
        roi = spm_data_read(vroi);
        roipos = find(roi);

%--------------------------------------------------------------------------
% Compares the voxels coordinates from template and ROI to-be-tested
        if isempty(roipos) || isempty(tplpos)
            if isempty(roipos) && isempty(tplpos)
                prec(i) = 1;
                rec(i) = 1;
            else
                prec(i) = 0;
                rec(i) = 0;
            end
        else
            tp(i) = sum(ismember(roipos,tplpos));
            prec(i) = tp(i)/length(roipos);
            rec(i) = tp(i)/length(tplpos);
        end
    end
    precision(d) = mean(prec);
    recall(d) = mean(rec);
    f1(d) = 2*precision(d)*recall(d)/(precision(d)+recall(d));
end

%--------------------------------------------------------------------------
% Saves the results in a csv file
tb = table(algorithm,precision,recall,f1);
writetable(tb,[tboutdir,filesep,roitype{1},'_dmngnoise.csv']);

%==========================================================================
%% regiongrowing
%==========================================================================
clear
close all

%--------------------------------------------------------------------------
% input dataset paths
datadir = {'/home/andre/github/tmp/fmroi_qc/dataset/fmroi-regiongrowing'};

%--------------------------------------------------------------------------
% Loads the template images
fmroirootdir = '/home/andre/github/fmroi';
srcpath = fullfile(fmroirootdir,'templates',...
    'syndata','complex-shapes.nii.gz');
vsrc = spm_vol(srcpath);
srcvol = spm_data_read(vsrc);

testdir = fullfile(fmroirootdir,'etc','test_data');
premaskfn = {fullfile(testdir,'premask-sphere_lhpc_radius_08_center_x58y57z27.nii.gz');...
                fullfile(testdir,'premask-sphere_rhpc_radius_08_center_x33y57z27.nii.gz');...
                fullfile(testdir,'premask-sphere_tetra_radius_09_center_x47y61z56.nii.gz');...
                fullfile(testdir,'premask-sphere_cone_radius_15_center_x46y84z58.nii.gz')};

premaskcell = cell(4,1);
for n = 1:length(premaskfn)
    vpre = spm_vol(premaskfn{n});
    premaskcell{n} = spm_data_read(vpre);
end

s1 = readtable(fullfile(testdir,'external_spiral.csv'));
s2 = readtable(fullfile(testdir,'internal_spiral.csv'));

%--------------------------------------------------------------------------
% create the output folders
rootoutdir = '/home/andre/github/tmp/fmroi_qc';
tboutdir = fullfile(rootoutdir,'statstable');
if ~isfolder(tboutdir)
    mkdir(tboutdir)
end

%--------------------------------------------------------------------------
% Extracts the input/output variables: ROI algorithm, ROI type, precision, etc...
datafolder = cell(length(datadir),1);
algorithm = cell(length(datadir),1);
roitype = cell(length(datadir),1);
precision = zeros(length(datadir),1);
recall = zeros(length(datadir),1);
f1 = zeros(length(datadir),1);
for d = 1:length(datadir)
    [~,datafolder{d},~] = fileparts(datadir{d});
    algorithm{d} = datafolder{d}(1:strfind(datafolder{d},'-')-1);
    roitype{d} = datafolder{d}(strfind(datafolder{d},'-')+1:end);
    roistruc = dir(datadir{d});
    roinames = cell(length(roistruc),1);
    for s = 1:length(roistruc)
        if ~roistruc(s).isdir
            roinames{s} = roistruc(s).name;
        end
    end
    roinames(cellfun(@isempty,roinames)) = [];
    
    tp = zeros(length(roinames),1); % true positive
    prec = zeros(length(roinames),1); % precision
    rec = zeros(length(roinames),1); % recall
    for i = 1:length(roinames)
        disp(['Working on ',datafolder{d},' ROI ',num2str(i)]);
        
        % extracts the seed coordinates
        seedidx = str2double(roinames{i}(...
            (strfind(roinames{i},'_seed_')+length('_seed_')):...
            (strfind(roinames{i},'_diffratio_')-1)));
        [x,y,z] = ind2sub(size(srcvol),seedidx);
        seed = [x,y,z];
    
        % extracts the maximum magnitude difference to the seed
        diffratio = str2double(roinames{i}(...
            (strfind(roinames{i},'_diffratio_')+length('_diffratio_')):...
            (strfind(roinames{i},'_grwmode_')-1)));

        % growing mode: ascending, descending, similarity
        grwmode = roinames{i}(...
            (strfind(roinames{i},'_grwmode_')+length('_grwmode_')):...
            (strfind(roinames{i},'_nvox_')-1));

        % ROI size
        nvox = str2double(roinames{i}(...
            (strfind(roinames{i},'_nvox_')+length('_nvox_')):...
            (strfind(roinames{i},'_premask_')-1)));

        % premask name
        premaskname = roinames{i}(...
            (strfind(roinames{i},'_premask_')+length('_premask_')):...
            (strfind(roinames{i},'.nii')-1));

%--------------------------------------------------------------------------
% Defines the template ROI voxels coordinates
        vroi = spm_vol(fullfile(datadir{d},roinames{i}));
        roi = spm_data_read(vroi);
        roipos = find(roi);

%--------------------------------------------------------------------------
% Defines the template ROI voxels coordinates
        if diffratio == inf % spiral test
            switch grwmode
                case 'ascending'
                    tplpos = s1.index(1:nvox);

                case 'descending'
                    tplpos = [s1.index(1);s2.index(1:nvox-1)];
                
                case 'similarity'
                    if seedidx == s1.index(1) % external spiral
                        tplpos = s1.index(1:nvox);
                    else % internal spiral
                        tplpos = s2.index(1:nvox);
                    end
            end

        else 
            if strcmp(premaskname,'srcvol') % shape test
                seedval = srcvol(seedidx);
                
                if seedval == 1
                    tplpos = find(srcvol==1);                    

                elseif seedval>=3 && seedval<=4
                    tplpos = find(srcvol>=3 & srcvol<=4);

                elseif seedval==5
                    tplpos = find(srcvol==5);

                elseif seedval==5.2
                    tplpos = find(srcvol==5.2);

                elseif seedval==5.4
                    tplpos = find(srcvol==5.4);

                elseif seedval==5.6
                    tplpos = find(srcvol==5.6);

                elseif seedval==5.8
                    tplpos = find(srcvol==5.8);

                elseif seedval>=7 && seedval<=8
                    tplpos = find(srcvol>=7 & srcvol<=8);

                elseif seedval>=9 && seedval<=10
                    tplpos = find(srcvol>=9 & srcvol<=10);

                elseif seedval>=11 && seedval<=12
                    tplpos = find(srcvol>=11 & srcvol<=12);
                end

            else % shape test premasked
                seedval = srcvol(seedidx);
                preidx = find(contains(premaskfn,premaskname));
                premask = premaskcell{preidx};                
                srcvolmask = srcvol.*premask;
                
                if seedval == 1
                    tplpos = find(srcvolmask==1);                    

                elseif seedval>=3 && seedval<=4
                    tplpos = find(srcvolmask>=3 & srcvolmask<=4);

                elseif seedval==5
                    tplpos = find(srcvolmask==5);

                elseif seedval==5.2
                    tplpos = find(srcvolmask==5.2);

                elseif seedval==5.4
                    tplpos = find(srcvolmask==5.4);

                elseif seedval==5.6
                    tplpos = find(srcvolmask==5.6);

                elseif seedval==5.8
                    tplpos = find(srcvolmask==5.8);

                elseif seedval>=7 && seedval<=8
                    tplpos = find(srcvolmask>=7 & srcvolmask<=8);

                elseif seedval>=9 && seedval<=10
                    tplpos = find(srcvolmask>=9 & srcvolmask<=10);

                elseif seedval>=11 && seedval<=12
                    tplpos = find(srcvolmask>=11 & srcvolmask<=12);
                end
            end
        end

%--------------------------------------------------------------------------
% Compares the voxels coordinates from template and ROI to-be-tested
        if isempty(roipos) || isempty(tplpos)
            if isempty(roipos) && isempty(tplpos)
                prec(i) = 1;
                rec(i) = 1;
            else
                prec(i) = 0;
                rec(i) = 0;
            end
        else
            tp(i) = sum(ismember(roipos,tplpos));
            prec(i) = tp(i)/length(roipos);
            rec(i) = tp(i)/length(tplpos);
        end      
    end
    precision(d) = mean(prec);
    recall(d) = mean(rec);
    f1(d) = 2*precision(d)*recall(d)/(precision(d)+recall(d));
end

%--------------------------------------------------------------------------
% Saves the results in a csv file
tb = table(algorithm,precision,recall,f1);
writetable(tb,[tboutdir,filesep,roitype{1},'_syndata.csv']);

%==========================================================================
%% drawmask
%==========================================================================
clear
close all

%--------------------------------------------------------------------------
% input dataset paths
% datadir = {'/media/andre/data8t/fmroi/tmp/fmroi_qc/dataset/fmroi-drawmask'};
datadir = {'/home/andre/github/tmp/dataset/fmroi-drawmask/';...
            '/home/andre/github/tmp/dataset/afni-drawmask';...
            '/home/andre/github/tmp/dataset/fsl-drawmask';...
            '/home/andre/github/tmp/dataset/mricrogl-drawmask'};
    
% '/home/andre/github/tmp/fmroi_qc/dataset/fmroi-drawmask';...
%            '/home/andre/github/tmp/fmroi_qc/dataset/afni-drawmask';...
%            '/home/andre/github/tmp/fmroi_qc/dataset/mricrongl-drawmask'};

%--------------------------------------------------------------------------
% Loads the template images
% vsrc = spm_vol('/media/andre/data8t/fmroi/tmp/fmroi_qc/dataset/templates/syntheticdata.nii');
vsrc = spm_vol('/home/andre/github/tmp/dataset/templates/complex-shapes.nii.gz');
srcvol = spm_data_read(vsrc);
srcvol(srcvol~=1) = 0;

%--------------------------------------------------------------------------
% create the output folders
% rootoutdir = '/media/andre/data8t/fmroi/tmp/fmroi_qc';
rootoutdir = '/home/andre/github/tmp/fmroi_qc';
tboutdir = fullfile(rootoutdir,'statstable');
if ~isfolder(tboutdir)
    mkdir(tboutdir)
end

%--------------------------------------------------------------------------
% Extracts the input/output variables: ROI algorithm, ROI type, precision, etc...
datafolder = cell(length(datadir),1);
algorithm = cell(length(datadir),1);
roitype = cell(length(datadir),1);
precision = zeros(length(datadir),1);
recall = zeros(length(datadir),1);
f1 = zeros(length(datadir),1);
for d = 1:length(datadir)
    [~,datafolder{d},~] = fileparts(datadir{d});
    algorithm{d} = datafolder{d}(1:strfind(datafolder{d},'-')-1);
    roitype{d} = datafolder{d}(strfind(datafolder{d},'-')+1:end);
    roistruc = dir(datadir{d});
    roinames = cell(length(roistruc),1);
    for s = 1:length(roistruc)
        if ~roistruc(s).isdir
            roinames{s} = roistruc(s).name;
        end
    end
    roinames(cellfun(@isempty,roinames)) = [];
    
    tp = zeros(length(roinames),1); % true positives
    prec = zeros(length(roinames),1); % precision
    rec = zeros(length(roinames),1); % recall
    for i = 1:length(roinames)
        disp(['Working on ',datafolder{d},' ROI ',num2str(i)]);

%--------------------------------------------------------------------------
% Defines the template ROI voxels coordinates
        tplpos = find(srcvol);

%--------------------------------------------------------------------------
% Loads ROI and defines the ROI voxels coordinates
        vroi = spm_vol(fullfile(datadir{d},roinames{i}));
        roi = spm_data_read(vroi);
        roipos = find(roi);
        
%--------------------------------------------------------------------------
% Compares the voxels coordinates from template and ROI to-be-tested        
        if isempty(roipos) || isempty(tplpos)
            if isempty(roipos) && isempty(tplpos)
                prec(i) = 1;
                rec(i) = 1;
            else
                prec(i) = 0;
                rec(i) = 0;
            end
        else
            tp(i) = sum(ismember(roipos,tplpos));
            prec(i) = tp(i)/length(roipos);
            rec(i) = tp(i)/length(tplpos);
        end
    end
    precision(d) = mean(prec);
    recall(d) = mean(rec);
    f1(d) = 2*precision(d)*recall(d)/(precision(d)+recall(d));
end

%--------------------------------------------------------------------------
% Saves the results in a csv file
tb = table(algorithm,precision,recall,f1);
writetable(tb,[tboutdir,filesep,roitype{1},'_syndata.csv']);
