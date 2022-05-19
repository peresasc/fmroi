%%
% lda_searchlight_suj1.nii T1_suj1.nii
st = stgen('/home/andre/matlab/CoSMoMVPA_output/mytest/accuracies_brainspace/lda_searchlight_suj1.nii');

slices = getslices(st);

figure
subplot(1,3,1)
imagesc(slices{1})
set(gca,'YDir','normal')

subplot(1,3,2)
imagesc(slices{2})
set(gca,'YDir','normal')

subplot(1,3,3)
imagesc(slices{3})
set(gca,'YDir','normal')

