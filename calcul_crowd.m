function [ crowd_value ] = calcul_crowd( new_AC,M)
%���㴢������Ԫ�ص�ӵ������ֵ
%new_AC���ⲿ������
%s2���ⲿ�����������ӵ�����

s2 = size(new_AC,1);
%���ӵ��������ڵ���2���ܼ���ӵ������ֵ������ӵ������ֵȡ1
if s2 >= 2
    for i = 1:M         %Ŀ�꺯������M=2
        lim_f(i,1) = min(new_AC(:,i));         %Ŀ�꺯��i�ļ�Сֵ
        lim_f(i,2) = max(new_AC(:,i));        %Ŀ�꺯��i�ļ���ֵ
    end
    DD = [];
    crowd_value = [];
    %����Ŀ�꺯��
    for i = 1:M
        [~,ind] = sort(new_AC(:,i));        %��Ŀ�꺯��i��ֵ����ind��������val��ֵ
        %�����������е�����
        for j = 1:s2
            if j == 1
                DD(ind(j),i) = inf;     %����Ŀ�꺯��i�ļ�Сֵ��ӵ������ֵΪ�����
            elseif j == s2
                DD(ind(j),i) = inf;     %����Ŀ�꺯��i�ļ���ֵ��ӵ������ֵΪ�����
            else
                DD(ind(j),i) = new_AC(ind(j+1),i) - new_AC(ind(j-1),i)/2*(lim_f(i,2) - lim_f(i,1));     %����Ŀ�꺯��i�Ǳ߽���ӵ������ֵ
            end
        end
    end
    for jj = 1:s2
        crowd_value(jj) = sum(DD(jj,:));        %����������ӵ�ӵ������ֵ
    end
else
    crowd_value(1) = 1;
end
end