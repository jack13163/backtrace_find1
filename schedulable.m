function [ flag ] = schedulable(FPORDER, DSFR, PIPEFR, RT, TKS, PET, FP, UD)
%�жϵ�ǰϵͳ״̬�Ƿ�ɵ���
%flag���ɵ���Ϊ1������Ϊ0
UDFR = sortrows([UD;DSFR(UD)]',2);   %����������������(��������)
available = zeros(size(DSFR, 2), 2);       %����и���������Ŀǰ���õ�����
for i = 1:size(UDFR, 1)
    DSN = UDFR(i,1);    %������
    COTN1 = FPORDER(DSN, 1);      %ԭ������1
    COTN2 = FPORDER(DSN, 2);      %ԭ������1
    for j = 1:size(TKS, 1)          %j�����͹�
        if TKS(j, 2) == COTN1
            if TKS(j, 5) <= PET && TKS(j, 6) > PET
                available(DSN, 1) = available(DSN, 1) + TKS(j, 3) - (PET - TKS(j, 5)) * DSFR(DSN);
            else
                available(DSN, 1) = available(DSN, 1) + TKS(j, 3);
            end
        elseif TKS(j, 2) == COTN2
            if TKS(j, 5) <= PET && TKS(j, 6) > PET
                available(DSN, 2) = available(DSN, 2) + TKS(j, 3) - (PET - TKS(j, 5)) * DSFR(DSN);   %����״̬
            else
                available(DSN, 2) = available(DSN, 2) + TKS(j, 3);  %�ǹ���״̬
            end
        end
    end
end

total = zeros(1, size(FPORDER, 1));
for i=1:size(available, 1)
    if FP(FPORDER(i, 1)) ~= 0
        total(i) = available(i,1);
    else
        total(i) = available(i,1) + available(i,2);
    end
end

%����Լ��
K = size(UDFR, 1);
tag = zeros(1,K);
for i=1:K
    arfai = RT * UDFR(i,2);
    DSN = UDFR(i,1);
    
    if (i==K && total(DSN) >= 4 * K * arfai) || total(DSN) >= 2 * K * arfai                 %ͳ����һ�����ڲ���Ҫ���͹�����
        tag(i) = 1;
    elseif (i==K && total(DSN) + 1 < 2 * K * arfai ) || total(DSN) + 1 < K * arfai      %�ж��Ƿ������������Լ��
        flag=0;
        %disp('�������Լ�������㣡');
        return;
    end
end

%�ڵ��������ڽ������Ͳ���
time = [];
cur = PET;
for i=1:K
	beta = available(i,1);
	arfai = RT * UDFR(i,2);
    %ת�˸�����������Ҫ����ԭ��
    if tag(i) == 0
        %������Ʒת��
        time = [time, cur];
        %��Ʒ�л���Ҫ���͹�
        if beta > 0 && beta < K * arfai && available(i,2) >= K * arfai - beta
            time = [time, cur + beta / PIPEFR];
        end
        cur = cur + K * arfai / PIPEFR;
    end
end

%���͹޿���ʱ��ideltime
TKSN = sortrows(TKS,6);
ideltime = TKSN(:,6)';
    
count = 0;%�����ù��͹޵ĸ���
for i=1:size(time,2)
	if ideltime(i) > time(i)
        count = count + 1;
	end
end

%�жϹ��͹��Ƿ�����Ҫʱ����
if count == 0
    flag = 1;
else
 	%disp('���͹޲��㣡');
    flag = 0;
end
end