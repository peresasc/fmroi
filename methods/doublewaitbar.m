function dwb = doublewaitbar(varargin)
% function dwb = doublewaitbar(dwb,progress1,text1,progress2,text2)
%
%   Displays a waitbar with two independent progress indicators for nested
%   loops or multi-stage operations. If no input is given, a new window is
%   created. If a handle to an existing waitbar (dwb) is passed, the bars
%   and labels are updated.
%
%   Inputs:
%             dwb : (optional) Handle vector from a previous call to
%                   doublewaitbar. If provided, updates the window instead
%                   of creating a new one.
%       progress1 : Progress value for the first bar (outer loop), between
%                   0 and 1.
%           text1 : String label to display above the first bar.
%       progress2 : Progress value for the second bar (inner loop), between
%                   0 and 1.
%           text2 : String label to display above the second bar.
%
%   Output:
%             dwb : Handle vector containing figure and UI component
%                   handles for the double waitbar. This handle should be
%                   passed again to update the bars.
%
%   Example:
%       dwb = doublewaitbar(); % initialize
%       for i = 1:N
%           for j = 1:M
%               dwb = doublewaitbar(dwb, i/N, 'Outer loop', j/M, 'Inner loop');
%               pause(0.01); % simulate work
%           end
%       end
%
% Author: Andre Peres, 2024, peres.asc@gmail.com
% Last update: Andre Peres, 28/05/2025, peres.asc@gmail.com

if ~isempty(varargin{1}) && ishandle(varargin{1}(1))
    dwb = varargin{1};
    if length(varargin) > 4
        p1 = varargin{2};
        t1 = varargin{3};
        p2 = varargin{4};
        t2 = varargin{5};
    elseif length(varargin) > 2
        p1 = varargin{2};
        t1 = varargin{3};
        p2 = 0;
        t2 = '';
    elseif length(varargin) > 1
        p1 = varargin{2};
        t1 = '';
        p2 = 0;
        t2 = '';
    else
        p1 = 0;
        t1 = '';
        p2 = 0;
        t2 = '';
    end

    if ~isempty(varargin{3})
        set(dwb(2),'String',t1);
    end

    if ~isempty(varargin{2})
        pos1 = get(dwb(3),'Position');
        pos1(3) = .92*p1;
        set(dwb(3),'Position',pos1)
    end

    if ~isempty(varargin{5})
        set(dwb(4),'String',t2)
    end

    if ~isempty(varargin{4})
        pos2 = get(dwb(5),'Position');
        pos2(3) = .92*p2;
        set(dwb(5),'Position',pos2)
    end
    
else
    if length(varargin) > 4
        p1 = varargin{2};
        t1 = varargin{3};
        p2 = varargin{4};
        t2 = varargin{5};
    elseif length(varargin) > 2
        p1 = varargin{2};
        t1 = varargin{3};
        p2 = 0;
        t2 = '';
    elseif length(varargin) > 1
        p1 = varargin{2};
        t1 = '';
        p2 = 0;
        t2 = '';
    else
        p1 = 0;
        t1 = '';
        p2 = 0;
        t2 = '';
    end

    scr = get(0, 'ScreenSize');
    x = .3;
    y = .15;
    hfig = figure('Name','Progress','MenuBar','none',...
        'ToolBar','none','Color','w','NumberTitle','off', ...
        'Position', [scr(3)/2-(scr(3)*x/2),scr(4)/2-(scr(4)*y/2),scr(3)*x,scr(4)*y]);

    % Outer progress bar (e.g., mask loop)
    ht1 = uicontrol(hfig,'Style','text','Units','normalized',...
        'Position',[.02,.7,.96,.2],'String',t1,'BackgroundColor','w');

    % Java fix due uicontrol missing vertical alignment property
    jh = findjobj(ht1);
    jh.setVerticalAlignment(javax.swing.JLabel.CENTER);


    bar1 = uicontrol(hfig,'Style','text','Units','normalized',...
        'BackgroundColor','b','Position',[.04,.55,.92*p1,.15]);

    % Inner progress bar (e.g., maskidx loop)
    ht2 = uicontrol(hfig,'Style','text','Units','normalized',...
        'Position',[.02,.3,.96,.2],'String',t2,'BackgroundColor','w');

    % Java fix due uicontrol missing vertical alignment property
    jh = findjobj(ht2);
    jh.setVerticalAlignment(javax.swing.JLabel.CENTER);

    bar2 = uicontrol(hfig,'Style','text','Units','normalized',...
        'BackgroundColor','g','Position',[.04,.15,.92*p2,.15]);

    dwb(1) = hfig;
    dwb(2) = ht1;
    dwb(3) = bar1;
    dwb(4) = ht2;
    dwb(5) = bar2;
end

drawnow;
