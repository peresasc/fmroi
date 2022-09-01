%% spheremask_cubicmask

datadir = {'/home/andre/github/tmp/fmroi_qc/dataset/fmroi-cubicmask';...
           '/home/andre/github/tmp/fmroi_qc/dataset/fmroi-cubicmask_odd';...
           '/home/andre/github/tmp/fmroi_qc/dataset/fmroi-cubicmask_even'};

rootoutdir = '/home/andre/github/tmp/fmroi_qc';
figoutdir = fullfile(rootoutdir,'figures');
if ~isfolder(figoutdir)
    mkdir(figoutdir)
end

tboutdir = fullfile(rootoutdir,'statstable');
if ~isfolder(tboutdir)
    mkdir(tboutdir)
end

mdloutdir = fullfile(rootoutdir,'models');
if ~isfolder(mdloutdir)
    mkdir(mdloutdir)
end

datafolder = cell(length(datadir),1);
Algorithm = cell(length(datadir),1);
roitype = cell(length(datadir),1);
mdlav = cell(length(datadir),1);
mdla = cell(length(datadir),1);
mdlv = cell(length(datadir),1);
mdlc = cell(length(datadir),3);
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

        vroi = spm_vol(fullfile(datadir{d},roinames{i}));
        roi = spm_data_read(vroi);
        [x1,y1,z1] = find3d(roi);
        masscenter(i,:) = mean([x1,y1,z1],1);

        [a,v,~,~] = roi_areavol(roi);
        area(i) = a;
        vol(i) = v;
    end

    %--------------------------------------------------------------------------
    % plot mdl
    switch roitype{d}
        case 'spheremask'
            ta = 4*pi()*(radius).^2;
            tv = 4/3*pi()*(radius).^3;
            tav = 3./radius;

        otherwise %case 'cubicmask'
            ta = 6*(radius).^2;
            tv = (radius).^3;
            tav = 6./radius;
    end
    mav = area./vol;

    close all

    mdlav{d} = fitlm(tav,mav);
    hfigav = figure;
    hptav = plot(tav,mav,'k.');
    hold on
    hmdlav = plot(mdlav{d});
    h45av = line([0 max(tav)],[0 max(tav)],'Color',[.6,.6,.6],'LineStyle','--');
    hmdlav(2).LineStyle = ':';
    delete(hmdlav(1))
    delete(hmdlav(3))
    delete(hmdlav(4))
    title(datafolder{d},'FontSize',16)
    xlabel('Theoretical Area/Volume','FontSize',12)
    ylabel('Observed Area/Volume','FontSize',12)
    legend('Data','Linear Fit','Expected fit','Location','southeast')
    ha2 = annotation('textbox', [0.7, 0.25, 0.5, 0.05],...
        'String', ['Alpha diff = ', num2str(round(mdlav{d}.Coefficients{2,1}-1,2))],...
        'EdgeColor','none','Interpreter', 'none');
    hold off
    mdl = mdlav{d};
    save([mdloutdir,filesep,datafolder{d},'_fitlm-areavol.m'],'mdl');
    saveas(hfigav,[figoutdir,filesep,datafolder{d},'_fitlm-areavol.png'])
    clear mdl

    mdla{d} = fitlm(ta,area);
    hfiga = figure;
    hpta = plot(ta,area,'k.');
    hold on
    hmdla = plot(mdla{d});
    h45a = line([0 max(ta)],[0 max(ta)],'Color',[.6,.6,.6],'LineStyle','--');
    hmdla(2).LineStyle = ':';
    delete(hmdla(1))
    delete(hmdla(3))
    delete(hmdla(4))
    title(datafolder{d},'FontSize',16)
    xlabel('Theoretical Area','FontSize',12)
    ylabel('Observed Area','FontSize',12)
    legend('Data','Linear Fit','Expected fit','Location','southeast')
    ha2 = annotation('textbox', [0.7, 0.25, 0.5, 0.05],...
        'String', ['Alpha diff = ', num2str(round(mdla{d}.Coefficients{2,1}-1,2))],...
        'EdgeColor','none','Interpreter', 'none');
    hold off
    mdl = mdla{d};
    save([mdloutdir,filesep,datafolder{d},'_fitlm-area.m'],'mdl');
    saveas(hfiga,[figoutdir,filesep,datafolder{d},'_fitlm-area.png'])
    clear mdl


    mdlv{d} = fitlm(tv,vol);
    hfigv = figure;
    hptv = plot(tv,vol,'k.');
    hold on
    hmdlv = plot(mdlv{d});
    h45v = line([0 max(tv)],[0 max(tv)],'Color',[.6,.6,.6],'LineStyle','--');
    hmdlv(2).LineStyle = ':';
    delete(hmdlv(1))
    delete(hmdlv(3))
    delete(hmdlv(4))
    title(datafolder{d},'FontSize',16)
    xlabel('Theoretical Volume','FontSize',12)
    ylabel('Observed Volume','FontSize',12)
    legend('Data','Linear Fit','Expected fit','Location','southeast')
    ha2 = annotation('textbox', [0.7, 0.25, 0.5, 0.05],...
        'String', ['Alpha diff = ', num2str(round(mdlv{d}.Coefficients{2,1}-1,2))],...
        'EdgeColor','none','Interpreter', 'none');
    hold off
    mdl = mdlv{d};
    save([mdloutdir,filesep,datafolder{d},'_fitlm-vol.m'],'mdl');
    saveas(hfigv,[figoutdir,filesep,datafolder{d},'_fitlm-vol.png'])
    clear mdl

    for i = 1:3
        mdlc{d,i} = fitlm(center(:,i),masscenter(:,i));
        hfigc = figure;
        hptc = plot(center(:,i),masscenter(:,i),'k.');
        hold on
        hmdlc = plot(mdlc{d,i});
        h45c = line([0 max(center(:,i))],[0 max(center(:,i))],'Color',[.6,.6,.6],'LineStyle','--');
        hmdlc(2).LineStyle = ':';
        delete(hmdlc(1))
        delete(hmdlc(3))
        delete(hmdlc(4))
        ax = 'xyz';
        title(datafolder{d},'FontSize',16)
        xlabel(['Set ',ax(i),' center'],'FontSize',12)
        ylabel([ax(i),' mass center'],'FontSize',12)
        legend('Data','Linear Fit','Expected fit','Location','southeast')
        ha2 = annotation('textbox', [0.7, 0.25, 0.5, 0.05],...
            'String', ['Alpha diff = ', num2str(round(mdlc{d,i}.Coefficients{2,1}-1,2))],...
            'EdgeColor','none','Interpreter', 'none');
        hold off
        mdl = mdlc{d,i};
        save([mdloutdir,filesep,datafolder{d},'_fitlm-center_',ax(i),'.m'],'mdl');
        saveas(hfigc,[figoutdir,filesep,datafolder{d},'_fitlm-center_',ax(i),'.png'])
        clear mdl
    end    
end
%--------------------------------------------------------------------------
% save stats table
models = {'mdlav';'mdla';'mdlv';'mdlc'};

for m = 1:length(models)
    clear mdl
    mdl = eval(models{m});

    RMSE_ThevsObs = zeros(size(mdl,1),1);
    Pearson_R = zeros(size(mdl,1),1);
    Alpha = zeros(size(mdl,1),1);
    Intercept = zeros(size(mdl,1),1);
    DoF = zeros(size(mdl,1),1);
    R2 = zeros(size(mdl,1),1);
    pValue = zeros(size(mdl,1),1);
    StdError = zeros(size(mdl,1),1);
    RMSE_fit = zeros(size(mdl,1),1);
    for dd = 1:size(mdl,2) % data dimension
        for d = 1:size(mdl,1) % data type
            if dd == 1
                x = [];
                y = [];
                for ddd = 1:size(mdl,2)
                    x = [x; mdl{d,dd}.Variables.x1];
                    y = [y; mdl{d,dd}.Variables.y];
                end
                RMSE_ThevsObs(d) = sqrt(mean((x-y).^2));
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
        if size(mdl,2) == 1
            tb = table(Algorithm,RMSE_ThevsObs,Pearson_R,Alpha,...
                Intercept,DoF,R2,pValue,StdError,RMSE_fit);
        else
            if dd == 1
                tb = table(Algorithm,RMSE_ThevsObs,Pearson_R,Alpha,Intercept,...
                    DoF,R2,pValue,StdError,RMSE_fit,'VariableNames',...
                    {'Algorithm','RMSE_ThevsObs',...
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
    writetable(tb,[tboutdir,filesep,roitype{1},'_',models{m},'.csv'])
end
%% image2mask

datadir = {'/home/andre/github/tmp/fmroi_qc/dataset/fmroi-img2mask';...
           '/home/andre/github/tmp/fmroi_qc/dataset/fmroi-img2mask_dmn'};

srcpath = {'/home/andre/github/fmroi/templates/syndata/syntheticdata.nii';...
           '/home/andre/github/fmroi/etc/default_templates/Neurosynth/default mode_association-test_z_FDR_0.01.nii.gz'};

rootoutdir = '/home/andre/github/tmp/fmroi_qc';
tboutdir = fullfile(rootoutdir,'statstable');
if ~isfolder(tboutdir)
    mkdir(tboutdir)
end

datafolder = cell(length(datadir),1);
algorithm = cell(length(datadir),1);
roitype = cell(length(datadir),1);
precision = zeros(length(datadir),1);
recall = zeros(length(datadir),1);
f1 = zeros(length(datadir),1);
for d = 1:length(datadir)
    vsrc = spm_vol(srcpath{d});
    srcvol = spm_data_read(vsrc);
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

        thrstr = roinames{i}(...
            (strfind(roinames{i},'threshold_')+length('threshold_')):...
            (strfind(roinames{i},'.nii')-1));

        minthr = str2double(thrstr(1:strfind(thrstr,'_')-1));
        maxthr = str2double(thrstr(strfind(thrstr,'_')+1:end));
        
        if minthr <= maxthr
            tplpos = find(srcvol>=minthr & srcvol<=maxthr);
        else
            tplpos = find(srcvol>=minthr | srcvol<=maxthr);
        end

        vroi = spm_vol(fullfile(datadir{d},roinames{i}));
        roi = spm_data_read(vroi);
        roipos = find(roi);
        
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

tb = table(algorithm,precision,recall,f1);
writetable(tb,[tboutdir,filesep,roitype{1},'_syndata.csv']);

%% clustermask

datadir = {'/home/andre/github/tmp/fmroi_qc/dataset/fmroi-clustermask'};

srcpath = {'/home/andre/github/fmroi/templates/syndata/syntheticdata.nii'};

rootoutdir = '/home/andre/github/tmp/fmroi_qc';
tboutdir = fullfile(rootoutdir,'statstable');
if ~isfolder(tboutdir)
    mkdir(tboutdir)
end

datafolder = cell(length(datadir),1);
algorithm = cell(length(datadir),1);
roitype = cell(length(datadir),1);
precision = zeros(length(datadir),1);
recall = zeros(length(datadir),1);
f1 = zeros(length(datadir),1);
for d = 1:length(datadir)
    vsrc = spm_vol(srcpath{d});
    srcvol = spm_data_read(vsrc);
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
        
        vroi = spm_vol(fullfile(datadir{d},roinames{i}));
        roi = spm_data_read(vroi);
        roipos = find(roi);
        mroi = mean(srcvol(roipos));

        if mroi <= 2
            minthr = 1;
            maxthr = 1;
        elseif mroi>=3 && mroi<=4
            minthr = 3;
            maxthr = 4;
        elseif mroi>=5 && mroi<=6
            minthr = 5;
            maxthr = 6;
        elseif mroi >= 7
            minthr = 7;
            maxthr = 12;
        end

        if minthr <= maxthr
            tplpos = find(srcvol>=minthr & srcvol<=maxthr);
        else
            tplpos = find(srcvol>=minthr | srcvol<=maxthr);
        end

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

tb = table(algorithm,precision,recall,f1);
writetable(tb,[tboutdir,filesep,roitype{1},'_syndata.csv']);

% lhpc = find(syndata==1);
% rhpc = find(syndata>=3 & syndata<=4);
% th1 = find(syndata==5);
% th2 = find(syndata==5.2);
% th3 = find(syndata==5.4);
% th4 = find(syndata==5.6);
% th5 = find(syndata==5.8);
% intspr = find(syndata>=7 & syndata<=8);
% cone = find(syndata>=9 & syndata<=10);
% extspr = find(syndata>=11 & syndata<=12);
% 
% tpl = {lhpc;rhpc;th1;th2;th3;th4;th5;intspr;cone;extspr};
% 
% thr = [1,1;3,4;5,5;5.2,5.2;5.4,5.4;5.6,5.6;5.8,5.8;7,8;9,10;11,12];