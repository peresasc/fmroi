function updatebuttergraph(hObject,~)

[tr,hp,lp,order] = getopts(hObject);
handles = guidata(hObject);

fs = 1/tr;
wn = [hp,lp]/(fs/2);
[b,a] = butter(order,wn,'bandpass');
[h,f] = freqz(b, a, 1024, fs);  % agora 'f' está em Hz

% Plot customizado
axes(handles.tools.settings.axes_butter)
plot(f, abs(h));
xlabel('Frequency (Hz)');
ylabel('Magnitude');
% title('Frequency response (Hz) of high-pass Butterworth filter');
grid on;