function updatebuttergraph(hObject,~)

handles = guidata(hObject);

% Retrieve Filter options
try
    tr = get(handles.tools.settings.edit_tr,'string');
    hp = get(handles.tools.settings.edit_highpass,'string');
    lp = get(handles.tools.settings.edit_lowpass,'string');
    order = get(handles.tools.settings.edit_filterorder,'string');

    tr = str2double(tr);
    hp = str2double(hp);
    lp = str2double(lp);
    order = str2double(order);
catch
    tr = [];
end

if ~isempty(tr) && ~isnan(tr) && ~isnan(order)

    if ~isnan(hp) || ~isnan(lp)
        fs = 1/tr;
        if ~isnan(hp) && ~isnan(lp)
            wn = [hp,lp]/(fs/2);
            [b,a] = butter(order,wn,'bandpass');
            [h,f] = freqz(b, a, 1024, fs);
        elseif isnan(lp)
            wn = hp/(fs/2);
            [b,a] = butter(order,wn,'high');
            [h,f] = freqz(b, a, 1024, fs);
        else
            wn = lp/(fs/2);
            [b,a] = butter(order,wn,'low');
            [h,f] = freqz(b, a, 1024, fs);
        end
        % Plot magnitude in hertz
        axes(handles.tools.settings.axes_butter)
        plot(f, abs(h));
        xlabel('Frequency (Hz)');
        ylabel('Magnitude');
        grid on;
    else
        lines = findall(handles.tools.settings.axes_butter, 'Type', 'line');
        delete(lines);
    end
else
    lines = findall(handles.tools.settings.axes_butter, 'Type', 'line');
    delete(lines);
end