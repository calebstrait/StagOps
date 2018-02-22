function MutualInhibitionToolkit
%% ---- ABOUT
% Author: Caleb Strait
% Paper: http://www.calebstrait.com/Strait-etal-PLoS-Bio-2015.pdf
% Repo: https://github.com/calebstrait/StagOps/MutualInhibitionToolkit.m
%
% How do you decide whether or not click buy using a network of
% cells? Somehow your brain can compile everything you know about a
% product and its competitors into a categorical decision.
%
% My graduate research aimed to reverse-engineering human choice processes
% by studying how reward information is compiled and tracked in the brain
% mid-decision.
%
% INPUT - This program accepts a standard format single-neuron spike
% frequency dataset collected from reward-sensitive neurons during two-
% option forced-choice decision tasks with asynchronous option offers.
%
% OUTPUT - 4 Figures
% 1) Proportion of cells encoding the first option's value over time
% 2) Proportion of cells encoding the second option's value over time
% 3) Animated scatter of neurons' option #1 coefs vs. their option #2 coefs
% 4) Correlation between option #1 coefs & option #2 coefs over time

%% ---- SET PARAMETERS

plotnum{1} = true;      % Proportion of cells coding VAL1 over time
plotnum{2} = true;      % Proportion of cells coding VAL2 over time
plotnum{3} = true;      % Are VAL1 coefs correlated with VAL2 coefs across cells?
plotnum{4} = true;      % Are VAL1 coefs correlated with VAL2 coefs during choice?

playback = 1/2;         % playback speed ratio
FontName = 'MonoSpaced';% font of all text
FontSize = 14;          % size of all text
binrange = 200:400;     % xaxis range (in bins) for plots #1,#2,#4
nStrReps = 20;          % number of stream repetitions; 1 for keyboard

color{1} = [.2 .2 .9];	% color of plot #1 (top left)
color{2} = [.1 .9 .1];  % color of plot #1 (top right)
color{3} = [.9 .2 .2];  % color of plot #1 (bottom left)
color{4} = [.9 .5 .3];  % color of plot #1 (bottom right)
color{5} = [ 1  1  1];  % color of text
color{6} = [ 0  0  0];  % color of background

%% ---- LOAD DATA

% Instantiate saved data structure
VSgamblingdata = {};

% Load saved data structure
load('VSgamblingdata.mat');

%% ---- CREATE EMPTY TRACES

[toplot_1,toplot_2] = deal(zeros(300,1));
toplot_3 = nan(length(VSgamblingdata),3,300);
toplot_4 = zeros(300,1);
tostar = zeros(300,1);

%% ---- FILL TRACES WITH CALCULATIONS

% FOR each consecutive time point in the decision
for t = binrange

    % Create matrices to hold calculations for all cells
    [R1s,R2s,P1s,P2s] = deal(zeros(length(VSgamblingdata),1));

    % FOR each cell: calculate these variables:
    for c = 1:length(VSgamblingdata)

        % Neuronal spikes stored in a histogram
        psth = VSgamblingdata{c}.psth;
        % Firing rate/trial in 50ms bins
        spikes = mean(psth(:,t:t+24),2);

        % Option #1 estimated expected value
        VAL1 = VSgamblingdata{c}.vars(:,3);
        % Option #2 estimated expected value
        VAL2 = VSgamblingdata{c}.vars(:,6);

        % Correlation btwn spikes & VAL1
        [R1,P1] = corrcoef(spikes, VAL1,'rows','complete');
        % Correlation btwn spikes & VAL2
        [R2,P2] = corrcoef(spikes, VAL2,'rows','complete');

        % Save calculations
        if isnan(R1(2,1)), R1(2,1) = 0;end
        if isnan(R2(2,1)), R2(2,1) = 0;end
        R1s(c) = R1(2,1);
        R2s(c) = R2(2,1);
        if P1(2,1) < .05 && ~isnan(P1(2,1)), P1s(c) = 1;end
        if P2(2,1) < .05 && ~isnan(P2(2,1)), P2s(c) = 1;end

    end

    %* FIGURE 1 ** Are spikes correlated with VAL1 in a significant % of cells?
     % calc: Percent of cells coding VAL1
    toplot_1(t) = 100 * sum(P1s)/length(VSgamblingdata);

    %* FIGURE 2 ** Are spikes correlated with VAL2 in a significant % of cells?
     % calc: Percent of cells coding VAL2
    toplot_2(t) = 100 * sum(P2s)/length(VSgamblingdata);

    %* FIGURE 3 ** Are VAL1 coefs correlated with VAL2 coefs across cells?
     % calc: VAL1 coefs
    toplot_3(:,1,t) = R1s;
     % calc: VAL2 coefs
    toplot_3(:,2,t) = R2s;

    %* FIGURE 4 ** Are VAL1 coefs correlated with VAL2 coefs during choice?
     % calc: R coef:[VAL1 Rcoefs] & [VAL2 Rcoefs]
    [R,P] = corrcoef(R1s, R2s,'rows','complete');
    toplot_4(t) = R(2,1);
     % calc: Bins reaching significance
    if P(2,1) < .05,tostar(t) = 1;end

end

%% ---- FIGURE SETUP

% Clear figures & console
close all
home

% Create a docked window to house our figures as subplots
figure('Color',color{6},'WindowStyle','docked');

% Format FIGURE 1
if(plotnum{1})
    s{1} = subplot(2,2,1);
    hold on
    title('\color{gray}1. \color{white}VALUE #1 CODING')
    axis tight square
    axis([min(binrange),max(binrange),0,max(toplot_2)]);
    xlabel('time(s)','FontSize',FontSize,'FontName',FontName);
    ylabel('% cells','FontSize',FontSize,'FontName',FontName);
    set(gca,'Color',color{6},'FontSize',FontSize,'FontName',FontName,...
        'XColor',color{5},'YColor',color{5},...
        'XTick',min(binrange):100:max(binrange),...
        'XTickLabel',strread(num2str...
        (((min(binrange):100:max(binrange))-200)/50),'%s')');
end

% Format FIGURE 2
if(plotnum{1})
    s{2} = subplot(2,2,2);
    hold on
    title('\color{gray}2. \color{white}VALUE #2 CODING')
    axis tight square
    axis([min(binrange),max(binrange),0,max(toplot_2)]);
    xlabel('time(s)','FontSize',FontSize,'FontName',FontName);
    ylabel('% cells','FontSize',FontSize,'FontName',FontName);
    set(gca,'Color',color{6},'FontSize',FontSize,'FontName',FontName,...
        'XColor',color{5},'YColor',color{5},...
        'XTick',min(binrange):100:max(binrange),...
        'XTickLabel',strread(num2str...
        (((min(binrange):100:max(binrange))-200)/50),'%s')');
end

% Format FIGURE 3
if(plotnum{3})
    subplot(2,2,3);
    hold on
    title('\color{gray}3. \color{white}VAL #1 R vs VAL #2 R')
    axis tight square
    axis([-.25,.25,-.25,.25]);
    xlabel('val1 R coef.','FontSize',FontSize,'FontName',FontName);
    ylabel('val2 R coef.','FontSize',FontSize,'FontName',FontName);
    set(gca,'Color',color{6},'FontSize',FontSize,'FontName',FontName,...
        'XColor',color{5},'YColor',color{5});
end

% Format FIGURE 4
if(plotnum{3} && plotnum{4})
    s{4} = subplot(2,2,4);
    hold on
    title('\color{gray}4. \color{white}VALUE DIFFERENCE or SUM?')
    axis tight square
    axis([min(binrange),max(binrange),min(toplot_4),max(toplot_4)]);
    xlabel('time(s)','FontSize',FontSize,'FontName',FontName);
    ylabel('scatter R coef.','FontSize',FontSize,'FontName',FontName);
    set(gca,'Color',color{6},'FontSize',FontSize,'FontName',FontName,...
        'XColor',color{5},'YColor',color{5},...
        'XTick',min(binrange):100:max(binrange),...
        'XTickLabel',strread(num2str...
        (((min(binrange):100:max(binrange))-200)/50),'%s')');
end

%% ---- STREAM TRACES

% FOR each stream repetition
for r = 1:nStrReps

    % FOR each time point in the choice task
    for t = binrange

        % Plot FIGURE 1
        if(plotnum{1})
            s{1} = subplot(2,2,1);
            plot(toplot_1(1:t),'LineWidth',2,'Color',color{1});
            hlineColor(10,[1 1 1]); % binopdf(10,124,0.0) > 0.05
            drawVerticals(t);
        end

        % Plot FIGURE 2
        if(plotnum{2})
            s{2} = subplot(2,2,2);
            plot(toplot_2(1:t),'LineWidth',2,'Color',color{2});
            hlineColor(10,[1 1 1]);
            drawVerticals(t)
        end

        % Plot FIGURE 3
        if(plotnum{3})
            s{3} = subplot(2,2,3);
            sc = scatter(toplot_3(:,1,t),toplot_3(:,2,t),[],color{4});
            cla(sc);
            Fit = polyfit(toplot_3(:,1,t),toplot_3(:,2,t),1);
            if tostar(t) == 1
                plot(toplot_3(:,1,t),polyval(Fit,toplot_3(:,1,t)),...
                    'Color',color{3},'LineWidth',2);
            else
                plot(toplot_3(:,1,t),polyval(Fit,toplot_3(:,1,t)),...
                    'Color',color{4},'LineWidth',2);
            end
        end

        % Plot FIGURE 4
        if(plotnum{3} && plotnum{4})
            s{4} = subplot(2,2,4);
            plot(toplot_4(1:t),'LineWidth',2,'Color',color{4});
            x = tostar(1:t)==1;
            y = toplot_4(x);
            xc = find(x == 1);
            plot(xc(y<0),y(y<0),'LineWidth',2,'Color',color{3});
            plot(xc(y>0),y(y>0),'LineWidth',2,'Color',color{3});
            hlineColor(0,[1 1 1]);
            drawVerticals(t)
        end

        % Pause tracing between time points
        pause((1/50)/playback);

    end

    % At stream end: send to keyboard or pause and then repeat
    if nStrReps == 1, keyboard;end
    pause(5);

    % Clear axes
    for x=1:4
        if(length(s) >= x)
            cla(s{x});
        end
    end

end

end
%% ---- RESOURCES
function drawVerticals(t)

% Draw vertical lines at option #1 on, option #2 on, & choice
if t>=250, vline(250,[.55 .55 1]); vline(250.5,[.55 .55 1]);end
if t>=300, vline(300,[.55 1 .55]); vline(300.5,[.55 1 .55]);end
if t>=355, vline(355,[1 1 1]); vline(355.5,[1 1 1]);end

end
