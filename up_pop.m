function pop = up_pop( pop, Gbest,Lbest,t,Tmax,bounds )
%����λ�ø��º���
%pop������Ⱥ
%Gbest������Ⱥ��ȫ��������
%Lbest������Ⱥ�ĸ���������
%t����������
%Tmax������������

[popsize, k] = size(pop);          %������Ⱥ�Ĺ�ģ�;��߱�����ά��
pp = exp(-10 * t/Tmax);              %����������Tmax

for i = 1:popsize
    %����λ���ƶ�
    for j = 1:k
        c1 = rand;
        c2 = 1 - c1;
        if rand < 0.5
            a = c1 * Lbest(i,j) + c2 * Gbest(i,j);
            b = abs(Lbest(i,j) - Gbest(i,j));
            pop(i,j) = a + b * randn;
        else
            pop(i,j) = Lbest(i,j);
        end
        if pop(i,j) < bounds(j,1)
            pop(i,j) = bounds(j,1);
        elseif pop(i,j)  > bounds(j,2)
            pop(i,j)  = bounds(j,2);
        end
    end
    %ִ�б���
    if pp > rand
        squence = getHDSquence(0.8536,1000);
        aa = ceil(k*squence(ceil(pp * 1000)));          %���ѡȡ�����ά��aa
        if aa == 0
            aa = k;
        end
        aalen = (bounds(aa,2) - bounds(aa,1));
        rang = aalen * pp;
        pop(i,aa) = pop(i,aa) + squence(ceil(pp * 1000)) * rang;       %����ά��aa������λ��
        %�����º����ӵ�λ�ò��ٶ������ڲ����ͽ�������Ϊ��ά�ȵı߽�ֵ
        if pop(i,aa) < bounds(aa,1)
            pop(i,aa) = bounds(aa,1) + aalen;
        elseif pop(i,aa) > bounds(aa,2)
            pop(i,aa) = bounds(aa,2) - aalen;
        end
    end
end
end

