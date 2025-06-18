% run_ds000030_analysis
tic
srcpath = '/media/andre/data8t/ds000030/derivatives/fmroi/funcpath.txt';
maskpath = '/media/andre/data8t/ds000030/derivatives/fmroi/Schaefer2018_400Parcels_7Networks_3x3x4mm.nii.gz';
outdir = '/media/andre/data8t/ds000030/derivatives/fmroi/timeseries_schaefer400';
optspath = '/media/andre/data8t/ds000030/derivatives/fmroi/opts.mat';

clear opts
auxopts = load(optspath);
varname = fieldnames(auxopts);
opts = auxopts.(varname{1});
opts.saveimg = 0;
opts.savestats = 1;
opts.savets = 1;
opts.groupts = 0;

runapplymask(srcpath,maskpath,outdir,opts)
toc

%%
 
clear opts

roinamespath = [];
opts.rsave = 1;
opts.psave = 1;
opts.zsave = 1;
opts.ftsave = 1;

tspath = '/media/andre/data8t/ds000030/derivatives/fmroi/schaefer100/timeseries/timeseriestab_mask-001.mat';
outdir = '/media/andre/data8t/ds000030/derivatives/fmroi/schaefer100/connectomes';

tic
runconnectome(tspath,outdir,roinamespath,opts)
toc
%% libsvm_downsampling_binary_permutation_parallel

% Load data
load('/media/andre/data8t/ds000030/derivatives/fmroi/connectomes/zfeatmat.mat');
partinfo = readmatrix("/media/andre/data8t/ds000030/derivatives/fmroi/participant_info.csv",'FileType','delimitedtext');
y_full = partinfo(:,2);
ft_full = ft;

% Class info
class_labels = [1, 2, 3, 4];
class_names = {'CONTROL', 'SCHZ', 'BIPOLAR', 'ADHD'};

nreps = 5;
nperm = 1000;

% Initialize results storage
pair_names = {};
f1_all = [];
p_f1_all = [];
acc_all = [];
p_acc_all = [];
prec_all = [];
p_prec_all = [];
rec_all = [];
p_rec_all = [];

fprintf('Running binary classification with LPOCV + permutation test (optimized)...\n');

for i = 1:length(class_labels)-1
    for j = i+1:length(class_labels)
        label_i = class_labels(i);
        label_j = class_labels(j);
        name_i = class_names{i};
        name_j = class_names{j};
        pair_name = sprintf('%s_vs_%s', name_i, name_j);
        fprintf('\n=== %s ===\n', pair_name);

        % Select data for the current pair
        idx = (y_full == label_i) | (y_full == label_j);
        xpair = ft_full(idx,:);
        ypair = y_full(idx);

        % Relabel classes as 1 and 2
        ypair_bin = zeros(size(ypair));
        ypair_bin(ypair == label_i) = 1;
        ypair_bin(ypair == label_j) = 2;

        n1 = sum(ypair_bin == 1);
        n2 = sum(ypair_bin == 2);
        n = min(n1, n2);

        % Initialize metric storage
        acc_real_all = [];
        f1_real_all = [];
        prec_real_all = [];
        rec_real_all = [];
        acc_perm_all = zeros(nperm, nreps);
        f1_perm_all = zeros(nperm, nreps);
        prec_perm_all = zeros(nperm, nreps);
        rec_perm_all = zeros(nperm, nreps);

        for rep = 1:nreps
            % Downsample to the smallest class size
            idx1 = find(ypair_bin == 1);
            idx2 = find(ypair_bin == 2);
            idx1 = idx1(randperm(length(idx1), n));
            idx2 = idx2(randperm(length(idx2), n));
            idx_sampled = [idx1; idx2];

            x = xpair(idx_sampled,:);
            y = ypair_bin(idx_sampled);

            % PCA reduction
            [coeff, score, ~, ~, explained] = pca(x);
            ncomp = find(cumsum(explained) >= 2/3*100, 1);
            x_pca = score(:, 1:ncomp);

            x1 = x_pca(y == 1, :);
            x2 = x_pca(y == 2, :);
            y1 = y(y == 1);
            y2 = y(y == 2);

            % Preallocate real prediction vectors
            total_pairs = n * n;
            ytest = [1; 2];
            ytrue_real = repmat(ytest,total_p,1);
            ypred_real = zeros(2 * total_pairs, 1);
            
            % Preallocate permuted results
            ytrue_perm_all = zeros(2 * total_pairs, nperm);
            ypred_perm_all = zeros(2 * total_pairs, nperm);

            for a = 1:n
                for b = 1:n
                    count = (a - 1) * n + b;
                    xtest = [x1(a,:); x2(b,:)];
                    

                    train_idx1 = setdiff(1:n, a);
                    train_idx2 = setdiff(1:n, b);
                    xtrain = [x1(train_idx1,:); x2(train_idx2,:)];
                    ytrain = [ones(n-1,1); 2*ones(n-1,1)];

                    % Real model
                    model_real = svmtrain(ytrain, xtrain, '-s 0 -t 0 -q');
                    yhat_real = svmpredict(ytest, xtest, model_real, '-q');

                    ypred_real((2*count)-1:2*count) = yhat_real;

                    % Permutation test using parfor
                    parfor p = 1:nperm
                        ytrain_perm = ytrain(randperm(length(ytrain)));
                        model_perm = svmtrain(ytrain_perm, xtrain, '-s 0 -t 0 -q');
                        yhat_perm = svmpredict(ytest, xtest, model_perm, '-q');

                        ytrue_perm_all((2*count)-1:2*count, p) = ytest;
                        ypred_perm_all((2*count)-1:2*count, p) = yhat_perm;
                    end
                end
            end

            % Compute real metrics
            acc = mean(ytrue_real == ypred_real);
            cmat = confusionmat(ytrue_real, ypred_real, 'Order', [1 2]);
            prec = diag(cmat) ./ sum(cmat, 1)';
            rec = diag(cmat) ./ sum(cmat, 2);
            f1 = 2 * (prec .* rec) ./ (prec + rec);
            prec(isnan(prec)) = 0;
            rec(isnan(rec)) = 0;
            f1(isnan(f1)) = 0;

            acc_real_all(end+1) = acc;
            prec_real_all(end+1) = mean(prec);
            rec_real_all(end+1) = mean(rec);
            f1_real_all(end+1) = mean(f1);

            % Compute permuted metrics
            for p = 1:nperm
                accp = mean(ytrue_perm_all(:,p) == ypred_perm_all(:,p));
                cmatp = confusionmat(ytrue_perm_all(:,p), ypred_perm_all(:,p), 'Order', [1 2]);
                precp = diag(cmatp) ./ sum(cmatp, 1)';
                recp = diag(cmatp) ./ sum(cmatp, 2);
                f1p = 2 * (precp .* recp) ./ (precp + recp);
                precp(isnan(precp)) = 0;
                recp(isnan(recp)) = 0;
                f1p(isnan(f1p)) = 0;

                acc_perm_all(p, rep) = accp;
                prec_perm_all(p, rep) = mean(precp);
                rec_perm_all(p, rep) = mean(recp);
                f1_perm_all(p, rep) = mean(f1p);
            end
        end

        % Average real metrics
        acc_real = mean(acc_real_all);
        prec_real = mean(prec_real_all);
        rec_real = mean(rec_real_all);
        f1_real = mean(f1_real_all);

        % Compute permutation distributions and p-values
        acc_perm_dist = mean(acc_perm_all, 2);
        prec_perm_dist = mean(prec_perm_all, 2);
        rec_perm_dist = mean(rec_perm_all, 2);
        f1_perm_dist = mean(f1_perm_all, 2);

        p_acc = mean(acc_perm_dist >= acc_real);
        p_prec = mean(prec_perm_dist >= prec_real);
        p_rec = mean(rec_perm_dist >= rec_real);
        p_f1 = mean(f1_perm_dist >= f1_real);

        % Store metrics
        pair_names{end+1} = pair_name;
        acc_all(end+1) = acc_real;
        p_acc_all(end+1) = p_acc;
        prec_all(end+1) = prec_real;
        p_prec_all(end+1) = p_prec;
        rec_all(end+1) = rec_real;
        p_rec_all(end+1) = p_rec;
        f1_all(end+1) = f1_real;
        p_f1_all(end+1) = p_f1;

        % Display metrics
        fprintf('Accuracy: %.2f%% (p = %.4f)\n', 100*acc_real, p_acc);
        fprintf('Precision: %.2f%% (p = %.4f)\n', 100*prec_real, p_prec);
        fprintf('Recall: %.2f%% (p = %.4f)\n', 100*rec_real, p_rec);
        fprintf('F1-score: %.2f%% (p = %.4f)\n', 100*f1_real, p_f1);
    end
end

% Build and display result table
results_table = table(pair_names', f1_all', p_f1_all', acc_all', p_acc_all', ...
                      prec_all', p_prec_all', rec_all', p_rec_all', ...
                      'VariableNames', {'pair_name', 'f1', 'p_f1', 'acc', 'p_acc', ...
                                        'precision', 'p_precision', 'recall', 'p_recall'});

fprintf('\n=== SUMMARY TABLE ===\n');
disp(results_table);

% Optional save:
% writetable(results_table, 'binary_lpo_results.csv');


%% libsvm_downsampling_binary_permutation

% Load data
load('/media/andre/data8t/ds000030/derivatives/fmroi/connectomes/zfeatmat.mat');
partinfo = readmatrix("/media/andre/data8t/ds000030/derivatives/fmroi/participant_info.csv",'FileType','delimitedtext');
y_full = partinfo(:,2);
ft_full = ft;

% Class info
class_labels = [1, 2, 3, 4];
class_names = {'CONTROL', 'SCHZ', 'BIPOLAR', 'ADHD'};

nreps = 1;
nperm = 10;

% Initialize results storage
pair_names = {};
f1_all = [];
p_f1_all = [];
acc_all = [];
p_acc_all = [];
prec_all = [];
p_prec_all = [];
rec_all = [];
p_rec_all = [];

fprintf('Running binary classification with LPOCV + permutation test (optimized)...\n');

for i = 1:length(class_labels)-1
    for j = i+1:length(class_labels)
        label_i = class_labels(i);
        label_j = class_labels(j);
        name_i = class_names{i};
        name_j = class_names{j};
        pair_name = sprintf('%s_vs_%s', name_i, name_j);
        fprintf('\n=== %s ===\n', pair_name);

        % Filter data for the current pair
        idx = (y_full == label_i) | (y_full == label_j);
        xpair = ft_full(idx,:);
        ypair = y_full(idx);

        % Relabel as 1 and 2
        ypair_bin = zeros(size(ypair));
        ypair_bin(ypair == label_i) = 1;
        ypair_bin(ypair == label_j) = 2;

        n1 = sum(ypair_bin == 1);
        n2 = sum(ypair_bin == 2);
        n = min(n1, n2);

        acc_real_all = [];
        f1_real_all = [];
        prec_real_all = [];
        rec_real_all = [];

        acc_perm_all = [];
        f1_perm_all = [];
        prec_perm_all = [];
        rec_perm_all = [];

        for rep = 1:nreps
            % Downsampling
            idx1 = find(ypair_bin == 1);
            idx2 = find(ypair_bin == 2);
            idx1 = idx1(randperm(length(idx1), n));
            idx2 = idx2(randperm(length(idx2), n));
            idx_sampled = [idx1; idx2];

            x = xpair(idx_sampled,:);
            y = ypair_bin(idx_sampled);

            % PCA
            [coeff, score, ~, ~, explained] = pca(x);
            ncomp = find(cumsum(explained) >= .9*100, 1);
            x_pca = score(:, 1:ncomp);

            x1 = x_pca(y == 1, :);
            x2 = x_pca(y == 2, :);
            y1 = y(y == 1);
            y2 = y(y == 2);

            ytrue_real = [];
            ypred_real = [];

            ytrue_perm = cell(nperm,1);
            ypred_perm = cell(nperm,1);
            tic
            for a = 1:n
                for b = 1:n                    
                    xtest = [x1(a,:); x2(b,:)];
                    ytest = [1; 2];

                    train_idx1 = setdiff(1:n, a);
                    train_idx2 = setdiff(1:n, b);
                    xtrain = [x1(train_idx1,:); x2(train_idx2,:)];
                    ytrain = [ones(n-1,1); 2*ones(n-1,1)];

                    % Real model
                    model_real = svmtrain(ytrain, xtrain, '-s 0 -t 0 -q');
                    yhat_real = svmpredict(ytest, xtest, model_real, '-q');

                    ytrue_real = [ytrue_real; ytest];
                    ypred_real = [ypred_real; yhat_real];
                    
                    % Permutations
                    for p = 1:nperm
                        ytrain_perm = ytrain(randperm(length(ytrain)));
                        model_perm = svmtrain(ytrain_perm, xtrain, '-s 0 -t 0 -q');
                        yhat_perm = svmpredict(ytest, xtest, model_perm, '-q');

                        ytrue_perm{p} = [ytrue_perm{p}; ytest];
                        ypred_perm{p} = [ypred_perm{p}; yhat_perm];
                    end
                end
            end
            toc
            % Compute real metrics
            acc = mean(ytrue_real == ypred_real);
            cmat = confusionmat(ytrue_real, ypred_real, 'Order', [1 2]);
            prec = diag(cmat) ./ sum(cmat, 1)';
            rec = diag(cmat) ./ sum(cmat, 2);
            f1 = 2 * (prec .* rec) ./ (prec + rec);
            prec(isnan(prec)) = 0;
            rec(isnan(rec)) = 0;
            f1(isnan(f1)) = 0;

            acc_real_all(end+1) = acc;
            prec_real_all(end+1) = mean(prec);
            rec_real_all(end+1) = mean(rec);
            f1_real_all(end+1) = mean(f1);

            % Compute permuted metrics
            for p = 1:nperm
                accp = mean(ytrue_perm{p} == ypred_perm{p});
                cmatp = confusionmat(ytrue_perm{p}, ypred_perm{p}, 'Order', [1 2]);
                precp = diag(cmatp) ./ sum(cmatp, 1)';
                recp = diag(cmatp) ./ sum(cmatp, 2);
                f1p = 2 * (precp .* recp) ./ (precp + recp);
                precp(isnan(precp)) = 0;
                recp(isnan(recp)) = 0;
                f1p(isnan(f1p)) = 0;

                acc_perm_all(p, rep) = accp;
                prec_perm_all(p, rep) = mean(precp);
                rec_perm_all(p, rep) = mean(recp);
                f1_perm_all(p, rep) = mean(f1p);
            end
        end

        % Average real metrics
        acc_real = mean(acc_real_all);
        prec_real = mean(prec_real_all);
        rec_real = mean(rec_real_all);
        f1_real = mean(f1_real_all);

        % Compute permutation distributions and p-values
        acc_perm_dist = mean(acc_perm_all, 2);
        prec_perm_dist = mean(prec_perm_all, 2);
        rec_perm_dist = mean(rec_perm_all, 2);
        f1_perm_dist = mean(f1_perm_all, 2);

        p_acc = mean(acc_perm_dist >= acc_real);
        p_prec = mean(prec_perm_dist >= prec_real);
        p_rec = mean(rec_perm_dist >= rec_real);
        p_f1 = mean(f1_perm_dist >= f1_real);

        % Store metrics
        pair_names{end+1} = pair_name;
        acc_all(end+1) = acc_real;
        p_acc_all(end+1) = p_acc;
        prec_all(end+1) = prec_real;
        p_prec_all(end+1) = p_prec;
        rec_all(end+1) = rec_real;
        p_rec_all(end+1) = p_rec;
        f1_all(end+1) = f1_real;
        p_f1_all(end+1) = p_f1;

        % Display metrics
        fprintf('Accuracy: %.2f%% (p = %.4f)\n', 100*acc_real, p_acc);
        fprintf('Precision: %.2f%% (p = %.4f)\n', 100*prec_real, p_prec);
        fprintf('Recall: %.2f%% (p = %.4f)\n', 100*rec_real, p_rec);
        fprintf('F1-score: %.2f%% (p = %.4f)\n', 100*f1_real, p_f1);
    end
end

% Build and display result table
results_table = table(pair_names', f1_all', p_f1_all', acc_all', p_acc_all', ...
                      prec_all', p_prec_all', rec_all', p_rec_all', ...
                      'VariableNames', {'pair_name', 'f1', 'p_f1', 'acc', 'p_acc', ...
                                        'precision', 'p_precision', 'recall', 'p_recall'});

fprintf('\n=== SUMMARY TABLE ===\n');
disp(results_table);

% Optional save:
% writetable(results_table, 'binary_lpo_results.csv');


%% libsvm_downsampling_binary

tic
% Load full feature matrix and labels
load('/media/andre/data8t/ds000030/derivatives/fmroi/connectomes/zfeatmat.mat');
partinfo = readmatrix("/media/andre/data8t/ds000030/derivatives/fmroi/participant_info.csv",'FileType','delimitedtext');
y_full = partinfo(:,2);
ft_full = ft;

% Class info
class_labels = unique(y_full);
class_names = {'CONTROL', 'SCHZ', 'BIPOLAR', 'ADHD'};

nreps = 1;
nfolds = 1000;  % number of test combinations per repetition
fprintf('Running pairwise binary classification for all class combinations...\n');

% Loop over all binary pairs
pair_idx = 0;
for i = 1:length(class_labels)-1
    for j = i+1:length(class_labels)
        pair_idx = pair_idx + 1;

        label_i = class_labels(i);
        label_j = class_labels(j);
        name_i = class_names{i};
        name_j = class_names{j};
        pair_name = sprintf('%s_vs_%s', name_i, name_j);
        fprintf('\n=== %s ===\n', pair_name);

        % Filter data for the current pair
        idx = (y_full == label_i) | (y_full == label_j);
        xpair = ft_full(idx,:);
        ypair = y_full(idx);

        % Relabel as 1 and 2 for binary classification
        ypair_bin = zeros(size(ypair));
        ypair_bin(ypair == label_i) = 1;
        ypair_bin(ypair == label_j) = 2;

        % Get class sizes and minimum
        n1 = sum(ypair_bin == 1);
        n2 = sum(ypair_bin == 2);
        min_class_size = min(n1, n2);

        % Initialize metrics
        confmat_all = zeros(2,2,nreps);
        f1_macro_all = zeros(nreps,1);

        for rep = 1:nreps
            % Downsample each class
            idx1 = find(ypair_bin == 1);
            idx2 = find(ypair_bin == 2);
            idx1 = idx1(randperm(length(idx1), min_class_size));
            idx2 = idx2(randperm(length(idx2), min_class_size));
            idx_sampled = [idx1; idx2];

            X = xpair(idx_sampled,:);
            y = ypair_bin(idx_sampled);

            % PCA after downsampling
            [coeff, score, ~, ~, explained] = pca(X);
            ncomp = find(cumsum(explained) >= .9*100, 1);
            x_pca = score(:, 1:ncomp);
            
            % Separate by class
            x1 = x_pca(y==1,:);
            y1 = y(y==1);
            x2 = x_pca(y==2,:);
            y2 = y(y==2);


            confmat_rep = zeros(2);

            for fold = 1:nfolds
                % Randomly select one sample per class for test
                r1 = randi(min_class_size);
                r2 = randi(min_class_size);
                Xtest = [x1(r1,:); x2(r2,:)];
                ytest = [y1(r1); y2(r2)];

                Xtrain = [x1(setdiff(1:min_class_size, r1),:); x2(setdiff(1:min_class_size, r2),:)];
                ytrain = [y1(setdiff(1:min_class_size, r1)); y2(setdiff(1:min_class_size, r2))];

                % Train SVM (linear, no weights)
                model = svmtrain(ytrain, Xtrain, '-s 0 -t 0 -q');
                ypred = svmpredict(ytest, Xtest, model, '-q');

                confmat_fold = confusionmat(ytest, ypred, 'Order', [1 2]);
                confmat_rep = confmat_rep + confmat_fold;
            end

            confmat_all(:,:,rep) = confmat_rep;

            % Metrics
            precision = diag(confmat_rep) ./ sum(confmat_rep,1)';
            recall = diag(confmat_rep) ./ sum(confmat_rep,2);
            f1 = 2 * (precision .* recall) ./ (precision + recall);

            precision(isnan(precision)) = 0;
            recall(isnan(recall)) = 0;
            f1(isnan(f1)) = 0;

            f1_macro_all(rep) = mean(f1);
        end

        % Final results for this pair
        confmat_mean = mean(confmat_all,3);
        confmat_norm = confmat_mean ./ sum(confmat_mean,2);  % row-normalized
        f1_macro_mean = mean(f1_macro_all);

        fprintf('Macro F1-score: %.2f%%\n', 100 * f1_macro_mean);
        fprintf('Normalized confusion matrix (per row):\n');
        disp(confmat_norm);
    end
end
toc
%% libsvm_downsampling_multiclas

% Load data
load('/media/andre/data8t/ds000030/derivatives/fmroi/connectomes/zfeatmat.mat');
partinfo = readmatrix("/media/andre/data8t/ds000030/derivatives/fmroi/participant_info.csv",'FileType','delimitedtext');
y_full = partinfo(:,2);
ft_full = ft;

class_labels = unique(y_full);
num_classes = numel(class_labels);
nreps = 10;
nfolds = 100;

% Determine minimum class size automatically
[freq, ~] = histcounts(y_full, [class_labels; max(class_labels)+1]);  % class frequencies
min_class_size = min(freq);  % smallest class count

% Initialize performance metrics
confmat_all = zeros(num_classes, num_classes, nreps);
f1_macro_all = zeros(nreps,1);

tic
for rep = 1:nreps
    fprintf('Repetition %d/%d\n', rep, nreps);
    
    % --- Stratified downsampling: min_class_size per class ---
    idx_sampled = [];
    for c = 1:num_classes
        idx = find(y_full == class_labels(c));
        idx = idx(randperm(length(idx), min_class_size));
        idx_sampled = [idx_sampled; idx];
    end

    % Reorder by class
    y = y_full(idx_sampled);
    X = ft_full(idx_sampled,:);
    [y, sort_idx] = sort(y);
    X = X(sort_idx, :);

    % PCA after downsampling
    [coeff, score, ~, ~, explained] = pca(X);
    ncomp = find(cumsum(explained) >= 2/3*100, 1);
    x_pca = score;%(:, 1:ncomp);

    % Separate data by class
    X_classes = cell(num_classes,1);
    y_classes = cell(num_classes,1);
    for c = 1:num_classes
        idx = find(y == class_labels(c));
        X_classes{c} = x_pca(idx,:);
        y_classes{c} = y(idx);
    end

    confmat_rep = zeros(num_classes);

    for fold = 1:nfolds
        % Randomly select one sample from each class for testing
        Xtest = zeros(num_classes, size(x_pca,2));  % <-- more flexible
        ytest = zeros(num_classes,1);
        Xtrain = [];
        ytrain = [];

        for c = 1:num_classes
            rand_idx = randi(min_class_size);
            X_c = X_classes{c};
            y_c = y_classes{c};

            Xtest(c,:) = X_c(rand_idx,:);
            ytest(c) = y_c(rand_idx);

            Xtrain = [Xtrain; X_c(setdiff(1:min_class_size, rand_idx), :)];
            ytrain = [ytrain; y_c(setdiff(1:min_class_size, rand_idx))];
        end

        % Train and test LIBSVM
        model = svmtrain(ytrain, Xtrain, '-s 0 -t 0 -q');
        ypred = svmpredict(ytest, Xtest, model, '-q');

        confmat_fold = confusionmat(ytest, ypred, 'Order', class_labels);
        confmat_rep = confmat_rep + confmat_fold;
    end

    confmat_all(:,:,rep) = confmat_rep;

    % Compute metrics
    precision = diag(confmat_rep) ./ sum(confmat_rep,1)';
    recall = diag(confmat_rep) ./ sum(confmat_rep,2);
    f1 = 2 * (precision .* recall) ./ (precision + recall);

    precision(isnan(precision)) = 0;
    recall(isnan(recall)) = 0;
    f1(isnan(f1)) = 0;

    f1_macro_all(rep) = mean(f1);
end
toc

% Final results
confmat_mean = mean(confmat_all,3);
confmat_norm = confmat_mean ./ sum(confmat_mean, 2);
f1_macro_mean = mean(f1_macro_all);

fprintf('\n=== FINAL RESULTS ===\n');
fprintf('Macro F1-score (mean): %.2f%%\n', 100 * f1_macro_mean);
fprintf('Mean confusion matrix:\n');
disp(confmat_norm);



%% libsvem_weights

% Carregar dados
load('/media/andre/data8t/ds000030/derivatives/fmroi/connectomes/zfeatmat.mat');
[coeff, score, latent, tsquared, explained, mu] = pca(ft);
ncomp = find(cumsum(explained) >= 2/3*100, 1);
ft = score;%(:,1:ncomp);


% Carregar rótulos
partinfo = readmatrix("/media/andre/data8t/ds000030/derivatives/fmroi/participant_info.csv",'FileType','delimitedtext');
y = partinfo(:,2);
% ft(y==3 | y==4,:) = [];
% y(y==3 | y==4) = [];

% Parâmetros
nfolds = 10;
nreps = 10;
class_labels = unique(y);
num_classes = length(class_labels);

% Inicializar armazenamento
confmat_all = zeros(num_classes, num_classes, nreps);

% Frequência das classes
[freq, ~] = histcounts(y, [class_labels; max(class_labels)+1]);  % counts por classe
class_weights = (numel(y) ./ (num_classes * freq));%.^2;               % pesos inversamente proporcionais
% class_weights = [0 1 1 1];
tic
for rep = 1:nreps
    idx = [];
    for c = 1:num_classes
        cidx = find(y == class_labels(c));
        cidx = cidx(randperm(length(cidx)));
        cfolds = mod(0:length(cidx)-1, nfolds) + 1;
        idx = [idx; [cidx(:), cfolds(:)]];
    end

    confmat_rep = zeros(num_classes);

    for fold = 1:nfolds
        test_idx = idx(idx(:,2) == fold, 1);
        train_idx = idx(idx(:,2) ~= fold, 1);

        Xtrain = ft(train_idx,:);
        ytrain = y(train_idx);
        Xtest  = ft(test_idx,:);
        ytest  = y(test_idx);

        % Construir string de pesos
        options = '-s 0 -t 0 -q';  % C-SVC, linear kernel, quiet
        for i = 1:num_classes
            options = [options sprintf(' -w%d %.4f', class_labels(i), class_weights(i))];
        end

        % Treinar com LIBSVM
        model = svmtrain(ytrain, Xtrain, options);

        % Previsão
        ypred = svmpredict(ytest, Xtest, model, '-q');

        % Matriz de confusão
        confmat_fold = confusionmat(ytest, ypred, 'Order', class_labels);
        confmat_rep = confmat_rep + confmat_fold;
    end

    confmat_all(:,:,rep) = confmat_rep;
end
toc

% =======================
% AVALIAÇÃO FINAL
% =======================

% Média da matriz de confusão
confmat_mean = mean(confmat_all,3);

% Precision, recall, F1-score macro
precision = diag(confmat_mean) ./ sum(confmat_mean,1)';
recall = diag(confmat_mean) ./ sum(confmat_mean,2);
f1 = 2 * (precision .* recall) ./ (precision + recall);

% Corrigir NaNs (caso alguma classe não tenha sido predita)
precision(isnan(precision)) = 0;
recall(isnan(recall)) = 0;
f1(isnan(f1)) = 0;

% F1-score macro
f1_macro = mean(f1);

% Exibir resultado final
fprintf('Macro F1-score: %.2f%%\n', 100 * f1_macro);

%% matlab_native
load('/media/andre/data8t/ds000030/derivatives/fmroi/connectomes/zfeatmat.mat');
[coeff,score,latent,tsquared,explained,mu] = pca(ft);
ncomp = find(cumsum(explained) >= 2/3*100, 1);


partinfo = readmatrix("/media/andre/data8t/ds000030/derivatives/fmroi/participant_info.csv",'FileType','delimitedtext');



% SVM Classification with PCA Features and Class Balancing

% Inputs
% ft : Feature matrix after PCA (samples x features)
% y  : Class labels vector (samples x 1), with integer class labels
ft = score;%(:,1:ncomp);
y = partinfo(:,2);
% Parameters
nfolds = 10;            % Number of folds for cross-validation
nreps = 5;              % Number of repetitions
class_labels = unique(y);
num_classes = length(class_labels);

% Compute class frequency and sample weights
[N, ~] = histcounts(y, [class_labels; max(class_labels)+1]);  % count samples per class
freq = N(:);                                                 % ensure column vector
class_weights = numel(y) ./ (numel(class_labels) * freq);    % inverse frequency
sample_weights = arrayfun(@(c) class_weights(class_labels == c), y); % per-sample weights
sample_weights = ones(size(sample_weights));
% Initialize performance storage
acc_all = zeros(nreps, 1);
confmat_all = zeros(num_classes, num_classes, nreps);  % 3D array for confusion matrices
tic
for rep = 1:nreps
    % Stratified folds
    idx = [];
    for c = 1:num_classes
        cidx = find(y == class_labels(c));
        cidx = cidx(randperm(length(cidx)));
        cfolds = mod(0:length(cidx)-1, nfolds) + 1;
        idx = [idx; [cidx(:), cfolds(:)]];
    end

    confmat_rep = zeros(num_classes);

    for fold = 1:nfolds
        test_idx = idx(idx(:,2) == fold, 1);
        train_idx = idx(idx(:,2) ~= fold, 1);

        Xtrain = ft(train_idx,:);
        ytrain = y(train_idx);
        Xtest  = ft(test_idx,:);
        ytest  = y(test_idx);
        wtrain = sample_weights(train_idx);

        % Train weighted SVM
        model = fitcecoc(Xtrain, ytrain, ...
            'Learners', templateSVM('KernelFunction','linear'), ...
            'Weights', wtrain);

        % Predict
        ypred = predict(model,Xtest);
        acc(fold) = sum(ypred == ytest) / length(ytest);

        % Confusion matrix for this fold
        confmat_fold = confusionmat(ytest, ypred, 'Order', class_labels);
        confmat_rep = confmat_rep + confmat_fold;
    end

    acc_all(rep) = mean(acc);
    confmat_all(:,:,rep) = confmat_rep;
end
toc
% Display overall results
fprintf('Mean classification accuracy: %.2f%%\n', 100 * mean(acc_all));
