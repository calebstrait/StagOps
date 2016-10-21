function FormatForBenVS(VSdata, Acls)
VSgamblingdata = {124};
for c = 1:124
    d.vars = zeros(length(VSdata{c}.gamble1st), 11);
    d.psth = zeros(length(VSdata{c}.gamble1st), 750);
    for x = 1:length(VSdata{c}.gamble1st)
        starttime = VSdata{c}.TS_option1_ON(x) - 5;
        stoptime = VSdata{c}.TS_option1_ON(x) + 10;
        found = find((VSdata{c}.spikes > starttime) & (VSdata{c}.spikes < stoptime));
        rel_spikes = VSdata{c}.spikes(found);
        rel_spikes = rel_spikes - starttime;
        psthline = histc(rel_spikes,[0:.02:15]);
        d.psth(x,:) = psthline(1:end-1);
        
        d.vars(x,1) = VSdata{c}.gamble1st(x);
        d.vars(x,2) = VSdata{c}.offerColor1st(x);
        d.vars(x,3) = VSdata{c}.gamble1st(x) * VSdata{c}.offerColor1st(x);
        d.vars(x,4) = VSdata{c}.gamble2nd(x);
        d.vars(x,5) = VSdata{c}.offerColor2nd(x);
        d.vars(x,6) = VSdata{c}.gamble2nd(x) * VSdata{c}.offerColor2nd(x);
        d.vars(x,7) = VSdata{c}.sideOfFirst(x);
        if (VSdata{c}.sideOfFirst(x) == 1 && VSdata{c}.choice1stvs2nd(x) == 1) || (VSdata{c}.sideOfFirst(x) == 2 && VSdata{c}.choice1stvs2nd(x) == 2) 
            d.vars(x,8) = 1;
        else
            d.vars(x,8) = 0;
        end
        d.vars(x,9) = VSdata{c}.choice1stvs2nd(x);
        if(VSdata{c}.choice1stvs2nd(x) == 1)
            d.vars(x,10) = VSdata{c}.gambleOutcome(x) * VSdata{c}.offerColor1st(x);
        else
            d.vars(x,10) = VSdata{c}.gambleOutcome(x) * VSdata{c}.offerColor2nd(x);
        end
        d.vars(x,11) = ismember(x, Acls{c}.valid);
    end
    VSgamblingdata(c) = {d};
end
save /Users/cstrait/Documents/Data/StagOps/VSgamblingdata.mat VSgamblingdata
end
