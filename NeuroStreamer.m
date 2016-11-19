function NeuroStreamer
home
close all
load VSgamblingdata.mat

ncells = 124;
[toplot_1,toplot_2,toplot_3] = deal(nan(750-25,1));
toplot_4 = nan(ncells,2,750-25);
for t = 1:750-25 % # bins in plot

    [R1s,R2s,P1s,P2s] = deal(zeros(ncells,1));
    for c = 1:ncells % # cells
    
        psth = VSgamblingdata{c}.psth;
        spikes = mean(psth(:,t:t+24),2); % Firing rate/trial in 50ms bins, or 25 bins
        
        EV1 = VSgamblingdata{c}.vars(:,3);
        
        EV2 = VSgamblingdata{c}.vars(:,6);
        
        [R1,P1] = corrcoef(spikes, EV1);
        [R2,P2] = corrcoef(spikes, EV2);
        
        R1s(c) = R1(2,1);
        R2s(c) = R2(2,1);
        if P1(2,1) < .05, P1s(c) = 1;end
        if P2(2,1) < .05, P2s(c) = 1;end
        
    end
    
    %- Are spikes correlated with EV1 in a significant proportion of cells?
    toplot_1(t) = sum(P1s)/ncells;    % To Plot: proportion of cells significantly coding EV 1
            
    %- Are spikes correlated with EV2 in a significant proportion of cells?
    toplot_2(t) = sum(P2s)/ncells;    % To Plot: proportion of cells significantly coding EV 2
            
    %- Are EV1 coefs correlated with EV2 coefs?
    [R,~] = corrcoef(R1s, R2s);
    toplot_3(t) = R(2,1);          % To Plot: R coef of [EV1 R coefs] & [EV2 R coefs]
            
    %- Scatter Plot
    toplot_4(:,1,t) = R1s;           % To Plot: R1s & R2s
    toplot_4(:,2,t) = R2s;
    
end

bck = [0 0 0];
txt = [1 1 1];
figure('Color',bck);
FS = 16;
subplot(2,2,1);
title('\color{white}VAL1 CODING');
hold on
axis tight square
axis([.5,750-24.5,min(toplot_1),max(toplot_1)]);
xlabel('time(s)','FontSize',FS,'FontName','Helvetica');
ylabel('% cells','FontSize',FS,'FontName','Helvetica');
set(gca,'Color',bck,'FontSize',FS,'FontName','Helvetica','XColor',txt,'YColor',txt);
subplot(2,2,2);
title('\color{white}VAL2 CODING')
hold on
axis tight square
axis([.5,750-24.5,min(toplot_2),max(toplot_2)]);
xlabel('time(s)','FontSize',FS,'FontName','Helvetica');
ylabel('% cells','FontSize',FS,'FontName','Helvetica');
set(gca,'Color',bck,'FontSize',FS,'FontName','Helvetica','XColor',txt,'YColor',txt);
subplot(2,2,3);
title('\color{white}CORR(VAL1 Rcoef,VAL2 Rcoef)')
hold on
axis tight square
axis([.5,750-24.5,min(toplot_3),max(toplot_3)]);
xlabel('time(s)','FontSize',FS,'FontName','Helvetica');
ylabel('R coef','FontSize',FS,'FontName','Helvetica');
set(gca,'Color',bck,'FontSize',FS,'FontName','Helvetica','XColor',txt,'YColor',txt);
subplot(2,2,4);
title('\color{white}RELATIVE VAL')
hold on
axis tight square
axis([-.25,.25,-.25,.25]);
xlabel('VAL1 R coef','FontSize',FS,'FontName','Helvetica');
ylabel('VAL2 R coef','FontSize',FS,'FontName','Helvetica');
set(gca,'Color',bck,'FontSize',FS,'FontName','Helvetica','XColor',txt,'YColor',txt);

%----STREAM-----%
for t = 1:750-25
    
    subplot(2,2,1);
    plot(toplot_1(1:t),'b-','LineWidth',2);
    if t >= 250, vline(250,[.5 .5 .5]);end
    if t >= 300, vline(300,[.5 .5 .5]);end
    
    subplot(2,2,2);
    plot(toplot_2(1:t),'c-','LineWidth',2);
    if t >= 250, vline(250,[.5 .5 .5]);end
    if t >= 300, vline(300,[.5 .5 .5]);end
    
    subplot(2,2,3);
    plot(toplot_3(1:t),'g-','LineWidth',2);
    if t >= 250, vline(250,[.5 .5 .5]);end
    if t >= 300, vline(300,[.5 .5 .5]);end
    
    sp4 = subplot(2,2,4);
    cla(sp4);
    scatter(toplot_4(:,1,t),toplot_4(:,2,t),'y');
    Fit = polyfit(toplot_4(:,1,t),toplot_4(:,2,t),1);
    plot(toplot_4(:,1,t),polyval(Fit,toplot_4(:,1,t)),'y','LineWidth',2);

    pause(0.02);
end
hold off

%keyboard
end