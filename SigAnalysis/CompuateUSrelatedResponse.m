function valueAnalyzedUS = CompuateUSrelatedResponseNew(fn)
    load(fn,'analyzedData');
    rs = analyzedData.raster;
   
 %% US response analysis 

    urs = rs([7 6 2 1 ]); % 0, 50% omission, 50 reward, 90 reward
  
% extract US response (subtract by iti baseline)
    TimeWin = 1:500;
    US_spikes = cellfun( @(x)1000*mean(x(:,TimeWin+3000),2),urs,'UniformOutput',0);
    [~,sig50Rvs50OM] = ranksum(US_spikes{2}, US_spikes{3});
    [~,sigExp] = ranksum(US_spikes{3}, US_spikes{4});
    [~,sig90Reward] = ranksum(US_spikes{1},US_spikes{4});    
    [~,sig50OM] = ranksum(US_spikes{1},US_spikes{2});
    [~,sig50R] = ranksum(US_spikes{1},US_spikes{3});
    if sig50OM
        if mean(US_spikes{2})-mean(US_spikes{1}) <0
            OM50sign = 1; % consistent with DA
        else
            OM50sign = -1;
        end
    else
        OM50sign = 0;
    end
    
    meanUS = cellfun(@mean, US_spikes);
    if (meanUS(1)- meanUS(4)<0)&&( meanUS(4)- meanUS(3)<0) % positive
        RPEsign = 1;
    elseif (meanUS(1)- meanUS(4)>0)&&( meanUS(4)- meanUS(3)>0) % negative
        RPEsign = 2;
    else
        RPEsign = 0;
    end

    if (meanUS(1)- meanUS(3)<0)&&( meanUS(3)- meanUS(4)<0) % positive
        EXPsign = 1;
    elseif (meanUS(1)- meanUS(3)>0)&&(meanUS(3)- meanUS(4)>0) % negative
        EXPsign = 2;
    else
        EXPsign = 0;
    end
    
    Rewardsign =  (meanUS(4)-meanUS(1))>0;
    
    valueAnalyzedUS = table(sig50Rvs50OM,sigExp,sig50OM,sig90Reward,RPEsign,EXPsign,sig50R,OM50sign,Rewardsign);
        
end