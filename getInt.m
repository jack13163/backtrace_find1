function [ r ] = getInt( a, length )
%根据[0~1]之间的随机数，返回一个[0~length]整数
%a：[0~1]
persistent squence;
if isempty(squence)
    squence = getHDSquence(0.29583,1000);
end

if a ~= 0
    a = squence(ceil(a * 1000));
end

if a == 1
    r = length;
else
    r = fix((length + 1) * a);
end
end

