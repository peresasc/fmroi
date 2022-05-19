%%

clear slices
st = updatepos(st);

slices = getslices(st);


subplot(1,3,1)
imagesc(slices{1})
set(gca,'YDir','normal')

subplot(1,3,2)
imagesc(slices{2})
set(gca,'YDir','normal')

subplot(1,3,3)
imagesc(slices{3})
set(gca,'YDir','normal')