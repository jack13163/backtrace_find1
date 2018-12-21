function [ new_AC ] = up_vac0( par_eff,old_AC,M,Na )
%�����ⲿ������
%par_eff����ѡ����
%old_AC���ⲿ������
%new_AC���µ��ⲿ������

%��ȡ�ⲿ�����������ӵĸ���
ss1 = size(old_AC,1);
%�ж��������ⲿ�����������ӵ�֧���ϵ
for i = 1:ss1
    bb1 = 0;
    bb2 = 0;
    for j = 1:M     %Ŀ�꺯���ĸ���M
        aa1 = old_AC(i,j);
        aa2 = par_eff(1,j);
        if aa2 < aa1
            bb1 = bb1 + 1;
        elseif aa2 == aa1
            bb2 = bb2 + 1;
        end
    end
    %�ж�֧���ϵ
    if bb1 == M         %��ѡ��֧��old_AC(i,:)������ѡ��֧���ⲿ�������еĵ�ǰ����
        old_AC(i,:) = inf;          %ɾ���ⲿ�������б���ѡ��֧�������
    elseif bb2 > 0 && bb1 == M - bb2        %��ѡ��֧��old_AC(i,:)������ѡ��֧���ⲿ�������еĵ�ǰ����
        old_AC(i,:) = inf;
    elseif bb1 + bb2 == 0       %��ѡ�߲�֧��old_AC(i,:)
        par_eff(1,:) = inf;         %ɾ����ѡ�����ӣ���ѡ�����ӱ���̭�����ܽ����ⲿ������
        break;      %��ǰ��ѡ��֧�����ⲿ�������еĵ�ǰ���ӣ��˳�
    elseif bb2 ~= 0 && bb1 == 0         %��ѡ�߲�֧��old_AC(i,:)
        par_eff(1,:) = inf;
        break;
    end
end
%����ѡ�߼��뵽��ʱ�ⲿ�������У���ʱ�ⲿ�������б�֧����������ڵ��б�Ϊinf���������
tmp_AC = [par_eff;old_AC]; 
new_AC = [];
%�����ϲ������ʱ�ⲿ������
for i = 1:ss1+1
    %�жϵ�ǰ�����Ƿ�����������֧�䣬�������������µ��ⲿ��������
    if tmp_AC(i,1) ~= inf
        new_AC = [new_AC;tmp_AC(i,:)];
    end
end
%��ȡ�µ��ⲿ�������Ĵ�С
ss2 = size(new_AC,1);
%���ⲿ��������Ԫ�ظ����������������
if ss2 > Na
    %��������Ŀ�꺯��
    for i = 1:M
        lim_f(i,2) = max(new_AC(:,i));       %��Ŀ�꺯��i�ļ���ֵ
        lim_f(i,1) = min(new_AC(:,i));        %��Ŀ�꺯��i�ļ�Сֵ
    end
    DD = [];        %ӵ����
    deep = [];
    for i = 1:M
       [val, ind] = sort(new_AC(:,i));        %��Ŀ�꺯��i�ĺ���ֵ���մ�С�����˳������
       %�ⲿ�����������Ӹ���ss2>50���ֵ�ǰֻ��һ�����ӽ����ⲿ���������ʵ�ǰ����£��ⲿ�����������Ӹ���ΪNA+1
       for j = 1:(Na+1)
           %���˵�ӵ�������
           if j == 1 || j == (Na+1)
               DD(ind(j),i) = inf;
           else
               DD(ind(j),i) = new_AC(ind(j+1),i) - new_AC(ind(j-1),i)/(lim_f(i,2) - lim_f(i,1));
           end
       end
    end
    %���ⲿ��������ɾ��ӵ������ֵ��С������
    for jj = 1:(Na+1)
       	deep(jj) = sum(DD(jj,:));
    end
   	[val, ind] = sort(deep);
    new_AC(ind(1),:) = [];
end
end