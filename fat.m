function [ eff,scheduleplan,pop ] = fat( pop )
%% ��������Ӧ��
%����ȡֵ��Χ[0,1]
%���߱���ά��w
%Ŀ�꺯������M=4
[popsize, w] = size(pop);   %������Ⱥ�Ĺ�ģ�;��߱�����ά��
eff = pop(:,1:w);
%����������Ⱥ
for p = 1:popsize
    %��������
    RT = 6;                                                     %פ��ʱ��
    DSFR = [333.3, 291.7, 625];                 %��������������(�ɼ�������������)
    PIPEFR = 1250;                                     %�ܵ���������
    FPORDER = [5,1;6,2;4,3];                     %������������˳��
    TKS = [
        16000,5,8000,0,0,0;
        34000,5,30000,0,0,0;
        34000,4,30000,0,0,0;
        34000,inf,0,0,0,0;
        34000,3,30000,0,0,0;
        16000,1,16000,0,0,0;
        20000,6,16000,0,0,0;
        16000,6,5000,0,0,0;
        16000,inf,0,0,0,0;
        30000,inf,0,0,0,0
        ];                                        %�͹޳�ʼ��棬������Զ�����������͹��Ϳ�ʼʱ��ͽ���ʱ��
    c1 = [0 11 12 13 7 15;
        10 0 9 12 13 7;
        13 8 0 7 12 13;
        13 12 7 0 11 12;
        7 13 12 11 0 11;
        15 7 13 12 11 0];           %�ܵ���ϳɱ�
    c2 = [0 11 12 13 10 15;
        11 0 11 12 13 10;
        12 11 0 10 12 13;
        13 12 10 0 11 12;
        10 13 12 11 0 11;
        15 10 13 12 11 0];          %�޵׻�ϳɱ�

    FP = [25992,49008,90000,0,0,0];        %���ϰ�(�ɼ���ԭ������)
    ET = [];              %���й��͹޼���
    DSFET = [0,0,0];   %���������һ�ε����ͽ���ʱ��
    PET = 0;                %�ܵ����һ��ת�˵Ľ���ʱ��(ͣ��Ҳ��¼����)
    %������Ϣ��¼��
    scheduleplan = [];
    %��ȡ����
    x = pop(p,1:w);    
    %ͳ�Ƴ�ʼʱ���͹޵ļ���
    for i=1:size(TKS,1)             
        if TKS(i,3) == 0
            ET = [ET,i];
        end
    end
    %δʵ�����ͼƻ�������������
    UD = [1,2,3];
    %�����жϵ�ǰ״̬�Ƿ���Ե���
	if schedulable(FPORDER, DSFR, PIPEFR, RT, TKS, PET, FP, UD) 
        %��������˳�����ѡ��һ���ǿյĹ��͹�Ϊ��������������
        for i = 1:3     %i����������
            for j = 1:2     %j������ϰ�
                for k = 1:size(TKS,1)       %k�����͹�
                    if FPORDER(i,j) == TKS(k,2)
                        Temp = DSFET(i);
                        %���㹩�͹޵Ĺ��ͽ���ʱ�䣬����ӵ����͹޶�Ӧ�Ĺ��ͼ�¼����
                        DSFET(i) = DSFET(i) + TKS(k,3) / DSFR(i);%DSFET(i)����������i�����һ�ι��ͽ���ʱ�䣬TKS(k,3)�����͹�k�ĵ�ǰ������DSFR(i)����������i����������
                        scheduleplan = [scheduleplan; i, k, Temp, DSFET(i), TKS(k,2)];
                        TKS(k, 4) = i;   %��¼������
                        TKS(k, 5) = Temp;   %��¼���Ϳ�ʼʱ��
                        TKS(k, 6) = DSFET(i);   %��¼���ͽ���ʱ��
                    end
                end
            end
        end
        %���ݵ��ȣ������������н�
        [ Flag,x,step,ET,UD,PET,DSFET,FP,TKS,scheduleplan ] = schedule( x,1,ET,UD,PET,DSFET,FP,TKS,scheduleplan,DSFR,PIPEFR,FPORDER,RT );
	else
        disp('��ʼ��治����ָ��������ϵͳ���ɵ��ȣ�\n');
	end
    %�������
    scheduleplan=sortrows(scheduleplan,1);

    if Flag
        %������Ӧ�Ⱥ���
        f1 = gnum(scheduleplan);              %���͹޸���
        f2 = gchange(scheduleplan);        %�������Ĺ��͹��л�����
        f3 = gdmix(scheduleplan, c1);      %�ܵ���ϳɱ�
        f4 = gdimix(scheduleplan, c2);     %�޵׻�ϳɱ�
    else
        f1 = inf;
        f2 = inf;
        f3 = inf;
        f4 = inf;
    end
    
    eff(p,1:w) = x(1:w);   %����
    eff(p,w+1) = f1;
    eff(p,w+2) = f2;
    eff(p,w+3) = f3;
    eff(p,w+4) = f4;
end
end