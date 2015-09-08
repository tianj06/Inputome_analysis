function [latency, rawl]= computeLatency(r, conditonNum,conditionName,bin,step,N_step,blOffset,resOffset)


for n = 1:length(conditonNum)
        r_temp = r{conditonNum(n)};
        if isempty(r_temp)
            l(n) = nan; % not available 
        else
            bl = mean(r_temp(:,blOffset-(1:bin)),2);
            p_binWin = [];
            for k = 1:N_step
                tw = resOffset + (step*(k-1)+1:step*(k-1)+bin);
                rw = mean(r_temp(:,tw),2);
                p_binWin(k) = signrank(rw,bl);
            end
            ind = strfind(p_binWin<0.05,[1 1 1 1 1]);
            if ~isempty(ind)
                rawl(n,:) = p_binWin;

                l(n) = (ind(1)-1)*step+25;
            else
                rawl(n,:) = nan(1,length(p_binWin<0.05));
                l(n) = nan;
            end
        end
end
latency = array2table(l,'VariableNames',conditionName);