function [ x ] = gchange( a )
%���͹��л�����
    K = 0;
    
    %��ȡת�˼�¼
    for i=1:size(a,1)
        if a(i,1) >= max(a(:,1))
            K = i;
            break;
        end
    end
    x = K - 1;
end