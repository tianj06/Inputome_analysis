function USjump = CompuateMixedStateResponse(fn,saveFlag,TimeWin)
if nargin < 3
    TimeWin = 1:500;
    if nargin < 2
        saveFlag = 0;
    end
end
    load(fn,'analyzedData');
    rs = analyzedData.raster;
   
 %% US response analysis 

    urs = rs([7 6 2 1 ]); % 0, 50% omission, 50 reward, 90 reward
  
% extract US response (subtract by iti baseline)
    US_spikes = cellfun( @(x)1000*(mean(x(:,TimeWin+3000),2)...
        -mean(x(:,TimeWin+2500),2)),urs,'UniformOutput',0);
    
    [~,sig50vs90] = ranksum(US_spikes{3}, US_spikes{4}); % 50% reward has higher jump than 90% reward?
    [~,sig50OMPre] = signrank(US_spikes{2}); % 50% om difference from before reward?
    dir50R = 0;

    if abs(mean(US_spikes{3})) < abs(mean(US_spikes{4}))
       sig50vs90 = 0;
    elseif sig50vs90
        if mean(US_spikes{3})>0
            dir50R = 1;
        else
            dir50R = -1;
        end
    end
    
    dir50OM = 0;
    if sig50OMPre
        if mean(US_spikes{2})<0
            dir50OM = -1;
        else
            dir50M = 1;
        end
    end
   
    USjump = table(sig50vs90,dir50R,sig50OMPre,dir50OM);
    if saveFlag
    save(fn,'-append','USjump');
    end    
end