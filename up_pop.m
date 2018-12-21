function pop = up_pop( pop, Gbest,Lbest,t,Tmax,bounds )
%粒子位置更新函数
%pop：粒子群
%Gbest：粒子群的全局引导者
%Lbest：粒子群的个体引导者
%t：迭代次数
%Tmax：最大迭代次数

[popsize, k] = size(pop);          %计算种群的规模和决策变量的维数
pp = exp(-10 * t/Tmax);              %最大迭代次数Tmax

for i = 1:popsize
    %粒子位置移动
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
    %执行变异
    if pp > rand
        squence = getHDSquence(0.8536,1000);
        aa = ceil(k*squence(ceil(pp * 1000)));          %随机选取变异的维度aa
        if aa == 0
            aa = k;
        end
        aalen = (bounds(aa,2) - bounds(aa,1));
        rang = aalen * pp;
        pop(i,aa) = pop(i,aa) + squence(ceil(pp * 1000)) * rang;       %更新维度aa的粒子位置
        %若更新后粒子的位置不再定义域内部，就将其设置为该维度的边界值
        if pop(i,aa) < bounds(aa,1)
            pop(i,aa) = bounds(aa,1) + aalen;
        elseif pop(i,aa) > bounds(aa,2)
            pop(i,aa) = bounds(aa,2) - aalen;
        end
    end
end
end

