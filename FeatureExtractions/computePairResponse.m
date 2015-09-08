function PairResult = computePairResponse(SpikeCounts,conditonPair,conditionName,r, ResOffset,TimeWin)
       % when using baseline for comparison, one needs to input
       % r,ResOffset,TimeWin
       sig = [];
       rocValue = [];
       for k = 1:length(conditonPair)
           pn = conditonPair{k};
           if pn(2)==0
               if ~isempty(r{pn(1)})
                   tempR = 1000*mean(r{pn(1)}(:,TimeWin+1000+ResOffset),2);
                   tempBl = 1000*mean(r{pn(1)}(:,1001-TimeWin),2);
                   rocValue(k) = auROC(tempR,tempBl);
                   sig(k) = signrank(tempR,tempBl);
               else
                   rocValue(k) = nan;
                   sig(k) = nan;
               end
           else
               if (~isempty(SpikeCounts{pn(1)}))&&(~isempty(SpikeCounts{pn(2)}))
                   rocValue(k) = auROC(SpikeCounts{pn(1)},SpikeCounts{pn(2)});
                   sig(k) = ranksum(SpikeCounts{pn(1)},SpikeCounts{pn(2)});
               else
                   rocValue(k) = nan;
                   sig(k) = nan;
               end
           end
       end
       PairResult = array2table([rocValue;sig],'VariableNames',conditionName,'RowNames',{'rocValue','Sig'});
