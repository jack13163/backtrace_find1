%��С������
clear all;
clc;
t0 = clock;     %��¼��ǰʱ��

%��Ҫ�ֶ����õĲ���
M = 4;                                  %Ŀ�꺯������
k = 50;                                 %���߱���ά��
bounds(1:k,1) =0;               %���߱���ȡֵ�½�
bounds(1:k,2) = 1;              %���߱���ȡֵ�Ͻ�
Na = 10;                               %�������������
popsize = 50;                      %����Ⱥ��ģ
Tmax =  1000;                         %����������
acnum = zeros(1,Tmax);

%��ʼ�����ӵ�λ��
range = (bounds(:,2) - bounds(:,1))';
pop = zeros(popsize,k);
pop(:,1:k) = ones(popsize,1) * bounds(:,1)' + ones(popsize,1) * range .* rand(popsize,k);

%�������ӵ���Ӧ�ȣ�����ʼ�����ӵĸ��������ߺ�ȫ��������
Lbest = fat(pop);        %��ʼ������������Ϊ������
AC = [];                                    %��ʼ��������Ϊ�ռ�
[AC,Gbest] = up_vac(Lbest,AC,k,M,popsize,Na);  %��ʼ����������ȫ��������

%��ѭ��
for t = 1:Tmax
    pop = up_pop(pop,Gbest,Lbest,t,Tmax,bounds);              %�������ӵ�λ��
    eff = fat(pop);                                                                         %�������ӵ���Ӧֵ
    Lbest = up_Lbest(eff,Lbest,k,M);                                         %�������ӵĸ���������
    [AC,Gbest] = up_vac(Lbest,AC,k,M,popsize,Na);                     %���´�������ѡ�����ӵ�ȫ��������
    %fprintf('%d\n', size(AC, 1));                   %������Ϣ�������ж������Ƿ��������ֲ����Ž�
    acnum(t) = size(AC,1);
end

%�������ͼ
fprintf('���ҵ�%d����֧���', size(AC, 1));
for i = 1:size(AC,1)
    figure(i);
    printshedgante(AC(i,1:k));
    grid on;     %��ʾ����
end
%���ִ��ʱ��
etime(clock,t0)
%��ʾ�������е�Ԫ�ظ���
figure(size(AC,1)+1);
plot(acnum);
%����������о���Ŀ��ֵ
AC(:,k+1:k+4)