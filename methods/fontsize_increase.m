function fontsize_increase(hObject)

h = findobj(hObject,'FontUnits','normalized');
for i = 1:length(h)
    fs = get(h(i),'fontsize');
    set(h(i),'fontsize',fs+fs*.1);
end