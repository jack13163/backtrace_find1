function [ x ] = gnum( a )
%���͹޸���
    TKSet = [];
    for i=1:size(a,1)
        if a(i,2) ~= 0 && ~ismember(a(i,2), TKSet)
            TKSet = [TKSet, a(i,2)];
        end
    end
    x = size(TKSet,2);      %���͹޵ĸ���
end