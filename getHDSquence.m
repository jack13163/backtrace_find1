function [ r ] = getHDSquence( x0, num )
%产生混沌序列
%x0：初始值
%num：序列长度
r = zeros(1,num);
xn = x0;
for i=1:num
    xn = 4*xn*(1-xn);
    r(i) = xn;
end
end

