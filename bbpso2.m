%最小化问题
clear all;
clc;
t0 = clock;     %记录当前时间

%需要手动设置的参数
M = 4;                                  %目标函数个数
k = 50;                                 %决策变量维数
bounds(1:k,1) =0;               %决策变量取值下界
bounds(1:k,2) = 1;              %决策变量取值上界
Na = 10;                               %储备集最大容量
popsize = 50;                      %粒子群规模
Tmax =  1000;                         %最大迭代次数
acnum = zeros(1,Tmax);

%初始化粒子的位置
range = (bounds(:,2) - bounds(:,1))';
pop = zeros(popsize,k);
pop(:,1:k) = ones(popsize,1) * bounds(:,1)' + ones(popsize,1) * range .* rand(popsize,k);

%评价粒子的适应度，并初始化粒子的个体引导者和全局引导者
Lbest = fat(pop);        %初始化个体引导者为其自身
AC = [];                                    %初始化储备集为空集
[AC,Gbest] = up_vac(Lbest,AC,k,M,popsize,Na);  %初始化储备集和全局引导者

%主循环
for t = 1:Tmax
    pop = up_pop(pop,Gbest,Lbest,t,Tmax,bounds);              %更新粒子的位置
    eff = fat(pop);                                                                         %评价粒子的适应值
    Lbest = up_Lbest(eff,Lbest,k,M);                                         %更新粒子的个体引导者
    [AC,Gbest] = up_vac(Lbest,AC,k,M,popsize,Na);                     %更新储备集并选择粒子的全局引导者
    %fprintf('%d\n', size(AC, 1));                   %调试信息，用于判断粒子是否过早陷入局部最优解
    acnum(t) = size(AC,1);
end

%输出甘特图
fprintf('共找到%d个非支配解', size(AC, 1));
for i = 1:size(AC,1)
    figure(i);
    printshedgante(AC(i,1:k));
    grid on;     %显示网格
end
%输出执行时间
etime(clock,t0)
%显示储备集中的元素个数
figure(size(AC,1)+1);
plot(acnum);
%输出储备集中决策目标值
AC(:,k+1:k+4)