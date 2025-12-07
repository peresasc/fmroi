function uicontrol_textalign(ui_handle)
% UICONTROL_TEXTALIGN Vertically centers text in legacy versions (Java)
%
% Compatibility Strategy:
%   < 2025 (Legacy): Uses Java (findjobj) to force Vertical Center
%                    alignment.
%   >= 2025 (Web):   Do nothing. Accepts default (Top) alignment to
%                    prevent errors.
%
% Usage:
%   uicontrol_textalign(handle)
%
% Author: Andre Peres, 2025, peres.asc@gmail.com
% Last update: Andre Peres, 04/12/2025, peres.asc@gmail.com

if isempty(ui_handle) || ~isvalid(ui_handle)
    return;
end

% 1. Check Version
v_str = version('-release');
v_year = str2double(v_str(1:4));

% 2. Apply Legacy Hack Only
if v_year < 2025
    % --- LEGACY MODE (Java Swing) ---
    try
        jh = findjobj(ui_handle);
        if ~isempty(jh)
            % Force Vertical Center
            jh.setVerticalAlignment(javax.swing.SwingConstants.CENTER);
            jh.repaint();
        end
    catch ME
        % Warning with MATLAB version info
        warning('uicontrol:LegacyFail', ...
            'MATLAB %s: Failed to align via Java. Error: %s',...
            version,ME.message);
    end
end