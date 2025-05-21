function [tr,hp,lp,order] = getopts(hObject)

handles = guidata(hObject);

opts.filter.tr = get(handles.tools.settings.edit_tr,'string');
opts.filter.highpass = get(handles.tools.settings.edit_highpass,'string');
opts.filter.lowpass = get(handles.tools.settings.edit_lowpass,'string');
opts.filter.order = get(handles.tools.settings.edit_filterorder,'string');
%--------------------------------------------------------------------------
% Get the parameters for filtering
if ~isempty(opts.filter)
    if isfield(opts.filter,'tr')
        %--------------------------------------------------------------------------
        % Convert opts.filter.tr to double
        if isnumeric(opts.filter.tr) && isscalar(opts.filter.tr)
            tr = double(opts.filter.tr);
            disp(['TR equal to ',num2str(tr),' s.']);

        elseif ischar(opts.filter.tr)
            tr = str2double(opts.filter.tr);

            if isnan(tr)
                tr = 1;
                disp(['Warning: Invalid TR value format. ',...
                    'TR set to ',num2str(tr),' s.']);
            else
                disp(['TR equal to ',num2str(tr),' s.']);
            end

        else
            tr = 1;
            disp(['Warning: Invalid TR value format. ',...
                'TR set to ',num2str(tr),' s.']);
        end
    else
        tr = 1;
        disp(['Warning: Invalid TR value format. ',...
            'TR set to ',num2str(tr),' s.']);
    end

    %--------------------------------------------------------------------------
    % Convert opts.filter.highpass to double
    if isfield(opts.filter,'highpass')
        if isnumeric(opts.filter.highpass) && isscalar(opts.filter.highpass)
            hp = double(opts.filter.highpass);
            disp(['High-pass filter of ',num2str(hp),' Hz will be applied.']);

        elseif ischar(opts.filter.highpass)
            hp = str2double(opts.filter.highpass);

            if strcmpi(opts.filter.highpass,'none')
                disp('Warning: High-pass filter will not be applied.');
            elseif isnan(hp)
                disp(['Warning: Invalid High-pass filter value format. ',...
                    'No filter will be applied.']);
            else
                disp(['High-pass filter of ',num2str(hp),' Hz will be applied.']);
            end

        else
            hp = nan;
            disp(['Warning: Invalid High-pass filter value format. ',...
                'No High-pass filter will be applied.']);
        end
    else
        hp = nan;
        disp(['Warning: Invalid High-pass filter value format. ',...
            'No High-pass filter will be applied.']);
    end

    %--------------------------------------------------------------------------
    % Convert opts.filter.lowpass to double
    if isfield(opts.filter,'lowpass')
        if isnumeric(opts.filter.lowpass) && isscalar(opts.filter.lowpass)
            lp = double(opts.filter.lowpass);
            disp(['Low-pass filter of ',num2str(lp),' Hz will be applied.']);

        elseif ischar(opts.filter.lowpass)
            lp = str2double(opts.filter.lowpass);

            if strcmpi(opts.filter.lowpass,'none')
                disp('Warning: Low-pass filter will not be applied.');
            elseif isnan(lp)
                disp(['Warning: Invalid Low-pass filter value format. ',...
                    'No filter will be applied.']);
            else
                disp(['Low-pass filter of ',num2str(lp),' Hz will be applied.']);
            end

        else
            lp = nan;
            disp(['Warning: Invalid Low-pass filter value format. ',...
                'No Low-pass filter will be applied.']);
        end
    else
        lp = nan;
        disp(['Warning: Invalid Low-pass filter value format. ',...
            'No Low-pass filter will be applied.']);
    end

    %--------------------------------------------------------------------------
    % Convert opts.filter.order to double
    if isfield(opts.filter,'order')        
        if isnumeric(opts.filter.order) && isscalar(opts.filter.order)
            order = double(opts.filter.order);
            disp(['Filter order equal to ',num2str(order),'.']);

        elseif ischar(opts.filter.order)
            order = str2double(opts.filter.order);

            if isnan(order)
                order = 1;
                disp(['Warning: Invalid order value format. ',...
                    'Order set to ',num2str(order),'.']);
            else
                disp(['Order equal to ',num2str(order),'.']);
            end

        else
            order = 1;
            disp(['Warning: Invalid order value format. ',...
                    'Order set to ',num2str(order),'.']);
        end
    else
        order = 1;
        disp(['Warning: Invalid order value format. ',...
                    'Order set to ',num2str(order),'.']);
    end
end

guidata(hObject,handles)