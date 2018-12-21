function [ Flag,X,step,ET,UD,PET,DSFET,FP,TKS,SchduleTable ] = schedule( X,step,ET,UD,PET,DSFET,FP,TKS,SchduleTable,DSFR,PIPEFR,FPORDER,RT )
%% 回溯调度(只需要找到一个可行解即可)
% 只需要依次遍历下去，若出现不可调度的地方就回溯
% 然后接着遍历，直到FP为空
    Flag = false;
    %保存旧值
    Old_step = step;
    Old_ET = ET;
    Old_UD = UD;
    Old_PET = PET;
    Old_DSFET = DSFET;
    Old_FP = FP;
    Old_TKS = TKS;
    Old_SchduleTable = SchduleTable;
    
    %记录遍历的足迹
    footprint = zeros(1,length(UD)+1);
        
    %结束条件
    if sum(FP) == 0 && isempty(UD)
        Flag = true;
    elseif step>25   %步长不得超过25
        Flag = false;
    else
        %深度优先遍历
        while ~all(footprint)&&~Flag&&step<=25%找到解，就返回
            %供油罐
            TK_NO=getInt(X(2*step-1), size(ET, 2));
            %蒸馏塔
            DS = UD(getInt(X(2*step), size(UD, 2)-1)+1);
            %可行性判断
            f1 = false;
            if TK_NO==0
                PipeStoptime  = roundn(getPipeStoptime(FPORDER, DSFR, RT, TKS, PET, FP, UD),-6);%四舍五入，取6位小数
                if PipeStoptime > 0 
                    f1 = true;
                    %停运
                    [SchduleTable,TKS,ET,PET] = stop(ET,PET,TKS,SchduleTable,PipeStoptime,DSFR);
                end
            else
                %试调度
                [Flag,PET,TKS,FP,ET,UD,DSFET,SchduleTable] = tryschedule(ET(TK_NO),DS,DSFET,PET,PIPEFR,RT,ET,UD,DSFR,TKS,FP,FPORDER,SchduleTable);
                %判断试调度是否成功，下一状态是否可以调度
               	if Flag && schedulable(FPORDER, DSFR, PIPEFR, RT, TKS, PET, FP, UD)
                    f1 = true;
                end
            end
            %判断试调度是否成功，下一状态是否可以调度
            if f1
                step = step + 1;
                [ Flag,X,step,ET,UD,PET,DSFET,FP,TKS,SchduleTable ] = schedule( X,step,ET,UD,PET,DSFET,FP,TKS,SchduleTable,DSFR,PIPEFR,FPORDER,RT );
            else
                Flag = false;
                
                %数据回滚
                [step,ET,UD,PET,DSFET,FP,TKS,SchduleTable] = rollback(Old_step,Old_ET,Old_UD,Old_PET,Old_DSFET,Old_FP,Old_TKS,Old_SchduleTable);
                
                %更改策略（先试试是否可以停运）
                for i = 1:length(footprint)
                    if footprint(i) == 0
                        %footprint中，第1位代表管道停运
                        if i == 1
                            while 0 ~= getInt(X(2*step-1),size(ET, 2))
                                X(2*step-1) = rand;
                            end
                            footprint(1) = 1;%停运标记
                        elseif isempty(ET)    %已经尝试过停运不行，并且无空罐
                            footprint = ones(size(footprint));
                        else    %尝试过停运不行，但有空罐
                            while 0 == getInt(X(2*step-1),size(ET, 2))
                                X(2*step-1) = rand;
                            end
                            while (i-1) ~= getInt(X(2*step),size(UD, 2)-1)+1
                                X(2*step) = rand;
                            end
                            footprint(i) = 1;%蒸馏塔标记
                        end
                        break;
                    end
                end
            end
        end
    end
end

%% 数据回滚
function [step,ET,UD,PET,DSFET,FP,TKS,SchduleTable] = rollback(Old_step,Old_ET,Old_UD,Old_PET,Old_DSFET,Old_FP,Old_TKS,Old_SchduleTable)
        step = Old_step;
        ET = Old_ET;
        UD = Old_UD;
        PET = Old_PET;
        DSFET = Old_DSFET;
        FP = Old_FP;
        TKS = Old_TKS;
        SchduleTable = Old_SchduleTable;
end

%% 计算可用原油总量
function [total] = gettotal(UD,DSFR,FP,TKS,PET,FPORDER)
	UDFR = sortrows([UD;DSFR(UD)]',2);   %蒸馏塔的炼油速率(升序排列)
	K = size(UDFR, 1);
	available = zeros(size(DSFR, 2), 2);       %库存中各个蒸馏塔目前可用的油量
	for i = 1:K
        DSN = UDFR(i,1);    %蒸馏塔
        COTN1 = FPORDER(DSN, 1);      %原油类型1
        COTN2 = FPORDER(DSN, 2);      %原油类型1
        for j = 1:size(TKS, 1)          %j代表供油罐
            if TKS(j, 2) == COTN1
                if TKS(j, 5) <= PET && TKS(j, 6) > PET
                    available(DSN, 1) = available(DSN, 1) + TKS(j, 3) - (PET - TKS(j, 5)) * DSFR(DSN);
                else
                    available(DSN, 1) = available(DSN, 1) + TKS(j, 3);
                end
            elseif TKS(j, 2) == COTN2
                if TKS(j, 5) <= PET && TKS(j, 6) > PET
                    available(DSN, 2) = available(DSN, 2) + TKS(j, 3) - (PET - TKS(j, 5)) * DSFR(DSN);   %供油状态
                else
                    available(DSN, 2) = available(DSN, 2) + TKS(j, 3);  %非供油状态
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
end

%% 停运
function [SchduleTable,TKS,ET,PET] = stop(ET,PET,TKS,SchduleTable,PipeStoptime,DSFR)
	PETOLD = PET;
    tk = 0;
    [feedendtimes,ind] = sort(TKS(:,6));
	%停运期间，各个蒸馏塔是否炼油结束
	for i = 1:size(TKS,1)
        if feedendtimes(i) > PET && feedendtimes(i) <= PET + PipeStoptime
            tk = i;
            break;
        end
	end
	%有油罐释放
	if tk ~= 0
        %更新转运结束时间为供油罐可用的时间
        PET = feedendtimes(tk);
        %将停运期间释放的供油罐添加到ET中
        ET = [ET, ind(tk)];      %将当前油罐添加到ET中
        %供油罐信息
        TKS(ind(tk), 2) = inf;
        TKS(ind(tk), 3) = 0;
        TKS(ind(tk), 4) = 0;
        TKS(ind(tk), 5) = 0;
        TKS(ind(tk), 6) = 0;
    else
        %正常停运
        PET = PET + PipeStoptime;
	end
	%更新转运记录表，不需要挑选供油罐供油
	SchduleTable = [SchduleTable; length(DSFR) + 1, 0, PETOLD, PET, 0];
end

%% 安全油量
function [V] = getVolume(DS,DSFET,PET,RT,UD,total,DSFR,PIPEFR)
	V = (DSFET(DS) - PET - RT) * PIPEFR;    %满足驻留时间约束
	VSec = inf;     %对于其他原油转运的安全体积
	for i=1:size(UD,2)
        if UD(i) ~= DS
            if DSFR(UD(i)) == max(DSFR)
                mincapacity = 2 * size(UD, 2) * RT * DSFR(UD(i));
            else
                mincapacity = size(UD, 2) * RT * DSFR(UD(i));
            end
            if VSec > PIPEFR / DSFR(UD(i)) * (total(UD(i)) - mincapacity)
                VSec = PIPEFR / DSFR(UD(i)) * (total(UD(i)) - mincapacity);
            end
        end
	end
	if VSec < V
        V = VSec;
	end
end

%% 试调度
function [Flag,PET,TKS,FP,ET,UD,DSFET,SchduleTable] = tryschedule(TK,DS,DSFET,PET,PIPEFR,RT,ET,UD,DSFR,TKS,FP,FPORDER,SchduleTable)
	%原油类型
	if FP(FPORDER(DS, 1)) == 0
        COT = FPORDER(DS, 2);      %原油类型2
	else
        COT = FPORDER(DS, 1);      %原油类型1
	end
	%库存总油量
	total = gettotal(UD,DSFR,FP,TKS,PET,FPORDER);    
    %安全的原油体积
    V = roundn(getVolume(DS,DSFET,PET,RT,UD,total,DSFR,PIPEFR),-6);
	%体积不可以低于特定的阈值
	if V >= 150
        if TKS(TK, 1) < V
            V = TKS(TK, 1);
        end
        if FP(COT) < V
            V = FP(COT);
        end

        %进料包
        FP(COT) = FP(COT) - V;

        %供油罐集合
        ET(ET==TK) = [];       %删除TK

        %转运期间释放的供油罐添加到供油罐集合
        for i = 1:size(TKS,1)
            if (TKS(i,6) > PET && TKS(i,6) <= PET + V / PIPEFR)
                %将当前油罐添加到ET中
                ET = [ET, i];
                %供油罐信息清空
                TKS(i, 2) = inf;
                TKS(i, 3) = 0;
                TKS(i, 4) = 0;
                TKS(i, 5) = 0;
                TKS(i, 6) = 0;
            end
        end

        %管道转运结束时间
        PETOLD = PET;
        PET = PET + V / PIPEFR;

        %结束供油时间
        DSFETOLD = DSFET(DS);
        DSFET(DS) = DSFETOLD + V / DSFR(DS);

        %供油罐的状态信息
        TKS(TK, 2) = COT;
        TKS(TK, 3) = V;
        TKS(TK, 4) = DS;
        TKS(TK, 5) = DSFETOLD;
        TKS(TK, 6) = DSFET(DS);
        Flag = true;
        
    	%更新转运记录和炼油记录
        SchduleTable = [SchduleTable;  length(DSFR)+1, TK, PETOLD, PET, COT];
    	SchduleTable = [SchduleTable;  DS, TK, DSFETOLD, DSFET(DS), COT];
        %判断DS是否炼油成功
     	if roundn(DSFET(DS),-6) == 240
            UD(UD==DS) = [];        %删除DS
     	end
    else
        Flag = false;
	end
end