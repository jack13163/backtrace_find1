function [ x ] = gdimix( a, c2 )
%�޵׻�ϴ���
%c2���޵׻�ϳɱ�
    m2 = zeros(6,6);
    K = 0;
    
    %��ȡת�˼�¼
    for i=1:size(a,1)
        if a(i,1) >= max(a(:,1))
            K = i;
            break;
        end
    end
    K = K - 1;
    record = a(1:K,:);
    record = sortrows(record,2);
    
    %ͳ�Ƹ����͹޵�ʹ�ô���
    A = record(:,2)';
    B = unique(A);
    tks = [];
    for i=1:size(B,2)
        tks(i) = sum(A(:)==B(i));
    end
    
	%�������ͼ�¼������޵׻�ϴ���
    for i=1:size(tks,2)     %i�����͹�
        tmp = 0;
        for j=1:(size(record,1) - 1)      %j�������ͼ�¼
            if record(j,2) == i
                tmp =  tmp + 1;
                if tmp >= tks(i)     %tks(i)���͹�i�е�ʹ�ô���
                    break;
                end
                if record(j,5) ~= record(j+1,5)
                    m2(record(j,5), record(j+1,5)) = m2(record(j,5), record(j+1,5)) + 1;
                end
            end
        end
    end
    x = sum(sum(m2.*c2));          %�޵׻�ϴ���
end

