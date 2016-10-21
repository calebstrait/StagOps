% 2x5=10 for offer and 4x5=20 for the choice period

%pvals = [0.0026 0.0026 0.048, 0.0003 0.0061 0.0001 0.001 0.0001 0.2981 0.0001]; %VM12 VS12 OF12 DA12 SA12
pvals = [0.9414 0.0001 0.0001 0.0007 0.2486 0.0001 0.0480 0.1174 0.0209 0.0001 0.0001 0.0003 0.0001 0.0001 0.0001 0.0005 0.1405 0.5439 0.0001 0.0055];
PVals = sort(pvals);

f = 0.05;
for i = length(PVals):-1:1
	d = (i/length(PVals)) * f;
    if PVals(i) > d
        fprintf('%.4f\n',PVals(i)); %print nonsig pvals
    end
end