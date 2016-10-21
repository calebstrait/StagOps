function FormatForBen(CESdata, Acls)
vmPFCdata = {156};
for c = 1:156
    d.vars = zeros(length(CESdata{c}.gamble1st), 11);
    d.psth = zeros(length(CESdata{c}.gamble1st), 750);
    for x = 1:length(CESdata{c}.gamble1st)
        starttime = CESdata{c}.TS_option1_ON(x) - 5;
        stoptime = CESdata{c}.TS_option1_ON(x) + 10;
        found = find((CESdata{c}.spikes > starttime) & (CESdata{c}.spikes < stoptime));
        rel_spikes = CESdata{c}.spikes(found);
        rel_spikes = rel_spikes - starttime;
        psthline = histc(rel_spikes,[0:.02:15]);
        d.psth(x,:) = psthline(1:end-1);
        
        d.vars(x,1) = CESdata{c}.gamble1st(x);
        d.vars(x,2) = CESdata{c}.offerColor1st(x);
        d.vars(x,3) = CESdata{c}.gamble1st(x) * CESdata{c}.offerColor1st(x);
        d.vars(x,4) = CESdata{c}.gamble2nd(x);
        d.vars(x,5) = CESdata{c}.offerColor2nd(x);
        d.vars(x,6) = CESdata{c}.gamble2nd(x) * CESdata{c}.offerColor2nd(x);
        d.vars(x,7) = CESdata{c}.sideOfFirst(x);
        if (CESdata{c}.sideOfFirst(x) == 1 && CESdata{c}.choice1stvs2nd(x) == 1) || (CESdata{c}.sideOfFirst(x) == 2 && CESdata{c}.choice1stvs2nd(x) == 2) 
            d.vars(x,8) = 1;
        else
            d.vars(x,8) = 0;
        end
        d.vars(x,9) = CESdata{c}.choice1stvs2nd(x);
        if(CESdata{c}.choice1stvs2nd(x) == 1)
            d.vars(x,10) = CESdata{c}.gambleOutcome(x) * CESdata{c}.offerColor1st(x);
        else
            d.vars(x,10) = CESdata{c}.gambleOutcome(x) * CESdata{c}.offerColor2nd(x);
        end
        d.vars(x,11) = ismember(x, Acls{c}.valid);
    end
    vmPFCdata(c) = {d};
end
save /Users/cstrait/Documents/Data/StagOps/vmPFCdata.mat vmPFCdata
end
