function [ r ] = getHDSquence( x0, num )
%������������
%x0����ʼֵ
%num�����г���
r = zeros(1,num);
xn = x0;
for i=1:num
    xn = 4*xn*(1-xn);
    r(i) = xn;
end
end

