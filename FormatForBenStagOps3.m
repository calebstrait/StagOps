function FormatForBenStagOps3
cd('/Users/cstrait/Documents/Data/StagOps/StagOps3');
folders = dir;
D = [];
for f = 4:numel(folders)-2
    cd(['/Users/cstrait/Documents/Data/StagOps/StagOps3/' folders(f).name]);
    files = dir('*.mat');
    for j = 1:length(files)
        filename = ['/Users/cstrait/Documents/Data/StagOps/StagOps3/' folders(f).name '/' files(j).name];
        e = load(filename);
        D = [D e.data];
    end
end
D(9697) = [];
StagOps3data = zeros(length(D), 15);
for x = 1:length(D)
    StagOps3data(x,1) = D(x).numOps;
    StagOps3data(x,2) = D(x).choice;
    StagOps3data(x,3) = D(x).left;
    StagOps3data(x,4) = D(x).right;
    StagOps3data(x,5) = D(x).center;
    D(x).notBlueOps(D(x).notBlueOps==0) = 12;
    D(x).notBlueOps(D(x).notBlueOps==1) = 13;
    D(x).notBlueOps(D(x).notBlueOps==2) = 11;
    D(x).notBlueOps(D(x).notBlueOps==11) = 1;
    D(x).notBlueOps(D(x).notBlueOps==12) = 2;
    D(x).notBlueOps(D(x).notBlueOps==13) = 3;
    StagOps3data(x,6) = D(x).notBlueOps(1);
    StagOps3data(x,7) = D(x).notBlueOps(2);
    StagOps3data(x,8) = D(x).notBlueOps(3);
    StagOps3data(x,9) = find(D(x).order==1); %Order of left
    StagOps3data(x,10) = find(D(x).order==2);
    StagOps3data(x,11) = find(D(x).order==3);
    StagOps3data(x,12) = D(x).gambleoutcome;
    D(x).positions(D(x).numOps==2) = 999;
    StagOps3data(x,13) = floor(D(x).positions/100); %Left position
    StagOps3data(x,14) = floor((D(x).positions - (100 * floor(D(x).positions/100)))/10);
    StagOps3data(x,15) = rem(D(x).positions,10);
end
keyboard
save /Users/cstrait/Documents/Data/StagOps/StagOps3/StagOps3data.mat StagOps3data
end
