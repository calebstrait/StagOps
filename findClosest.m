function [index,smallestDiff] = findClosest(val, vec)

smallestDiff = abs(vec(1) - val);
index = 1;
for i = 2:length(vec)
    diff = abs(vec(i) - val);
    if diff < smallestDiff
        smallestDiff = diff;
        index = i;
    end
end

end

