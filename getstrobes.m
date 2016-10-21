function strobes = getstrobes(EVT01,EVT02,EVT03,EVT04,EVT05,EVT06)
laststamp = EVT06(1);
strobes = [];
strobes(:,1) = EVT06;
r = 0;
n = 1;
while(r ~= -1)
    [r laststamp] = unbase5(laststamp,EVT01,EVT02,EVT03,EVT04,EVT05);
    if r ~= -1, strobes(n,2) = r;end
    n = n + 1;
end
end

function [r,laststamp] = unbase5(laststamp,EVT01,EVT02,EVT03,EVT04,EVT05)
rbase5 = 0;
broke = 0;
high = 999999999999;
for i = 1:6
    found = find(EVT01>laststamp);
    if isempty(found), low(1) = high;
    else low(1) = min(EVT01(found));
    end
    found = find(EVT02>laststamp);
    if isempty(found), low(2) = high;
    else low(2) = min(EVT02(found));
    end
    found = find(EVT03>laststamp);
    if isempty(found), low(3) = high;
    else low(3) = min(EVT03(found));
    end
    found = find(EVT04>laststamp);
    if isempty(found), low(4) = high;
    else low(4) = min(EVT04(found));
    end
    found = find(EVT05>laststamp);
    if isempty(found), low(5) = high;
    else low(5) = min(EVT05(found));
    end
    lowest = min(low);
    if lowest == high, broke = 1; break;end
    for j = 1:5
        if low(j) == lowest
            rbase5 = rbase5 + ((j-1)*10^(6-i));
            laststamp = lowest;
        end
    end
end
if(broke == 1)
    r = -1;
else
    r = base2dec(num2str(rbase5),5);
end
end