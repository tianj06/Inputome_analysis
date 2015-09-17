function CS = CompuateCSRelatedResponse(fn)

    %fn = 'Biscuit_2014-11-08_18-22-38_TT7_01_formatted.mat';
    load(fn,'analyzedData');
    rs = analyzedData.raster;
    
    
%%
% CS: 0 < 50 < 90
% 0 vs 90 significant
% 0 vs 50, 50 vs 90 same direction
    %%
    mergeCellTypes = @(A,B)([A;B]);
    crs = cellfun(mergeCellTypes, rs(1:4), rs(5:8),'UniformOutput',0);

    TimeWin = [1:500];
      
    % extract CS response (subtract by iti baseline)
    CS_spikes = cellfun(@(x)1000*mean(x(:,TimeWin+1000),2)-1000*mean(x(:,1001-TimeWin),2),crs,'UniformOutput',0);
    sig90vs0 = ranksum(CS_spikes{1},CS_spikes{3});
    meanSpikes = cellfun(@mean, CS_spikes);
    if ((meanSpikes(1)-meanSpikes(2))*(meanSpikes(2)-meanSpikes(3))>0)...
            && (sig90vs0<0.05)
        if (meanSpikes(1)-meanSpikes(2)>0)&&(meanSpikes(2)-meanSpikes(3)>0)
            csValue = 1;
        else
            csValue = -1;
        end
    else
        csValue = 0;
    end
   CS = table(csValue);
