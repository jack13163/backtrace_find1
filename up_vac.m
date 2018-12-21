function [ new_AC,Gbest ] = up_vac( AC,old_AC,k,M,popsize,Na )
%�����㷨���ⲿ���������Լ����ӵ�ȫ��������
%AC����ѡ��
%old_AC���ⲿ������
%new_AC�����º���ⲿ������
%Gbest�����º������ȫ��������
%popsize����Ⱥ��С

%size(AC,1)����ѡ�ߵ�����
for i = 1:size(AC,1)
    %��ÿ����ѡ�����ⲿ�������е�Ԫ�ؽ��бȽϣ����´�����
    old_AC = up_vac0(AC(i,:),old_AC,k,M,Na);
end
%�ⲿ�������Ѿ����£������浽new_AC��
new_AC = old_AC;
%������º���ⲿ��������ӵ������ֵ
crowd_value = calcul_crowd(new_AC,k,M);

Gbest_set = new_AC;
Gbest_crowd_val = crowd_value;
%�ⲿ�������е����Ӹ���
g_size = size(Gbest_set,1);
while g_size > Na                                        %�ⲿ�������е�����NA
    [val, ind] = sort(Gbest_crowd_val);         %�����º���ⲿ�������е����ӵ�ӵ������ֵ����
    Gbest_set(ind(1),:) = [];                           %ɾ��ӵ������ֵ��С��Ԫ��
    Gbest_crowd_val(ind(1)) = [];                 %ɾ��ӵ������ֵ��С��Ԫ�ص�ӵ������ֵ
    g_size = size(Gbest_set,1);                   %���¼����ⲿ�������е���������
end
%�������е����ӣ������ӵ�ȫ��������
for i = 1:popsize                                                    %���Ӹ���Ϊpopsize
    a1 = ceil(g_size * rand);                           %���ⲿ�����������ѡ����������
    a2 = ceil(g_size * rand);
    %�Ƚ��������ӵ�ӵ������ֵ��ѡ��ӵ������ֵ����ⲿ�������е�������Ϊ�����ӵ�ȫ��������
    if Gbest_crowd_val(a1) >= Gbest_crowd_val(a2)
        Gbest(i,:) = Gbest_set(a1,:);
    else
        Gbest(i,:) = Gbest_set(a2,:);
    end
end
end

