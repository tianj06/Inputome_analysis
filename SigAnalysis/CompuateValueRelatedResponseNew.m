function newCodingResults = CompuateValueRelatedResponseNew(fn,saveFlag)
if nargin <2
    saveFlag = 1;
end
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
        csValue(1) = 1;
        if (meanSpikes(1)-meanSpikes(2)>0)&&(meanSpikes(2)-meanSpikes(3)>0)
            csValue(2) = 1;
        else
            csValue(2) = -1;
        end
    else
        csValue(1) = 0;
        csValue(2) = 0;
    end
    

    delay_spikes = cellfun( @(x)1000*mean(x(:,3000-TimeWin),2)-1000*mean(x(:,1001-TimeWin),2),crs,'UniformOutput',0);
    sig90vs0 = ranksum(delay_spikes{1},delay_spikes{3});
    meanSpikes = cellfun(@mean, delay_spikes);
    if ((meanSpikes(1)-meanSpikes(2))*(meanSpikes(2)-meanSpikes(3))>0)...
            && (sig90vs0<0.05)
        delayValue(1) = 1;
        if (meanSpikes(1)-meanSpikes(2)>0)&&(meanSpikes(2)-meanSpikes(3)>0) 
            delayValue(2) = 1;
        else
            delayValue(2) = -1;
        end
    else
        delayValue(1) = 0;
        delayValue(2) = 0;
    end

    
    delay_spikes = cellfun( @(x)1000*mean(x(:,2500-TimeWin),2)-1000*mean(x(:,1001-TimeWin),2),crs,'UniformOutput',0);
    sig90vs0 = ranksum(delay_spikes{1},delay_spikes{3});
    meanSpikes = cellfun(@mean, delay_spikes);
    if ((meanSpikes(1)-meanSpikes(2))*(meanSpikes(2)-meanSpikes(3))>0)...
            && (sig90vs0<0.05)
        EarlydelayValue(1) = 1;
        if (meanSpikes(1)-meanSpikes(2)>0)&&(meanSpikes(2)-meanSpikes(3)>0) 
            EarlydelayValue(2) = 1;
        else
            EarlydelayValue(2) = -1;
        end
    else
        EarlydelayValue(1) = 0;
        EarlydelayValue(2) = 0;
    end
    
 %% 


    urs = rs([7 2 1 9]); % 0, 50 reward, 90 reward, free reward 
    omrs = rs([7 6 5]); % 0, 50% omission, 50 reward, 90 reward, free reward 
  
% extract US response (subtract by iti baseline)
    TimeWin = 1:500;
    US_spikes = cellfun( @(x)1000*mean(x(:,TimeWin+3000),2)-1000*mean(x(:,1001-TimeWin),2),urs,'UniformOutput',0);
    OMShort_spikes = cellfun( @(x)1000*mean(x(:,TimeWin+3000),2)-1000*mean(x(:,1001-TimeWin),2),omrs,'UniformOutput',0);

    TimeWin = 1:1000;
    OM_spikes = cellfun( @(x)1000*mean(x(:,TimeWin+3000),2)-1000*mean(x(:,1001-TimeWin),2),omrs,'UniformOutput',0);

% check expectation coding    
%  Expectation (US): 0 < 50 omission = 50 reward < 90 reward
% 0 vs 90 reward significant
% 0 vs 50 reward, 50 reward vs 90 reward same direction
% 50 omission vs 50 reward not significant
    sig90vs0 = ranksum(US_spikes{1},US_spikes{3});
    sig50vs50om = ranksum(US_spikes{2},OMShort_spikes{2});
    meanSpikes = cellfun(@mean, US_spikes);
    if ((meanSpikes(1)-meanSpikes(2))*(meanSpikes(2)-meanSpikes(3))>0)...
            && (sig90vs0<0.05) &&(sig50vs50om>0.05)
        usExpectation(1) = 1;
        if (meanSpikes(1)-meanSpikes(2)>0)&&(meanSpikes(2)-meanSpikes(3)>0) 
            usExpectation(2) = -1;
        else
            usExpectation(2) = 1;
        end
    else
        usExpectation(1) = 0;
        usExpectation(2) = 0;
    end

 % check reward coding   
 % Reward: 0 = 50 omission < 50 reward = 90 reward
% 0 vs 90 reward significant
% 50 reward vs 90 reward not significant
% 0 vs 90 omission not significant

    sig50vs90 = ranksum(US_spikes{2},US_spikes{3});
    sig0vs50om = ranksum(OM_spikes{1},OM_spikes{2});
    US_spikes_90vsdelay = 1000*mean(urs{3}(:,TimeWin+3000),2)-1000*mean(urs{3}(:,3001-TimeWin),2);
    sig90vsdealy = signrank(US_spikes_90vsdelay);
    sameDir = mean(US_spikes_90vsdelay)*(mean(US_spikes{3}) - mean(US_spikes{1}))>0;
    
    if (sig90vs0<0.05)&&(sig0vs50om>0.05)&&(sig50vs90>0.05)&&(sig90vsdealy<0.05)&&sameDir
        usReward(1) = 1;
        if meanSpikes(3)>meanSpikes(1)
            usReward(2) = 1;
        else
            usReward(2) = -1;
        end
    else
        usReward(1) = 0;
        usReward(2) = 0;
    end
    % RPE: 0 < 90 reward < 50 reward < free reward
    % method 1):
    % 90 reward vs 50 reward significant
    % 0 vs 90 reward, 90 reward vs 50 reward same direction
    if ((meanSpikes(1)-meanSpikes(3))*(meanSpikes(3)-meanSpikes(2))>0)...
            && (sig50vs90<0.05)
        usRPE1(1) = 1;  
        if ((meanSpikes(1)-meanSpikes(3)>0)&&(meanSpikes(3)-meanSpikes(2))>0)
            usRPE1(2) = -1;
        else
            usRPE1(2) = 1;
        end
    else
        usRPE1(1) = 0;
        usRPE1(2) = 0;
    end 

    % or 90 reward vs free reward significant
    % 0 vs 90 reward, 90 vs 50 reward, 50 reward vs free reward same direction
    usRPE2 = [nan, nan];
    if ~isempty(urs{4})
        if size(urs{4},1)>=5
            sig90vsfree = ranksum(US_spikes{3},US_spikes{4});           
            a = [meanSpikes(1)-meanSpikes(3),meanSpikes(3)-meanSpikes(2),...
                meanSpikes(2)-meanSpikes(4)];
            if (all(a>0)||all(a<0))&&(sig90vsfree<0.05)
                usRPE2(1) = 1;
                if all(a>0)
                    usRPE2(2) = -1;
                else
                    usRPE2(2) = 1; 
                end
            else
                usRPE2(1) = 0;
                usRPE2(2) = 0;
            end 
        end
    end

%     omission: 50 omission < 0
%     50 omission vs 0 significant
    meanOMspikes = cellfun(@mean,OM_spikes);    
    if(sig0vs50om<0.05)
        om(1) = 1;
        if meanOMspikes(2)<meanOMspikes(1);
            om(2) = 1;
        else
            om(2) = -1;
        end
    else
        om(1) = 0;
        om(2) = 0;
    end
     
% perfect RPE: 50 omission < 0 < 90 reward < 50 reward < free reward
% RPE and omission, same direction
% 50%omission significant different from 0
% 50%reward significant different from 0
    meanOMShortSpikes = cellfun(@mean,OMShort_spikes);    

    perfectRPE2 = [nan nan];
    if ~isempty(urs{4})
        if size(urs{4},1)>=5
            sig50vs0 = ranksum(US_spikes{2},US_spikes{1});
            a = [meanOMShortSpikes(2)-meanSpikes(1), meanSpikes(1)-meanSpikes(3),...
            meanSpikes(3)-meanSpikes(2),meanSpikes(2)-meanSpikes(4)];
            if (all(a>0)||all(a<0))&&(sig0vs50om<0.05)&&(sig0vs50om<0.05)
                perfectRPE2(1) = 1;
                if all(a>0)
                    perfectRPE2(2) = -1;
                else
                    perfectRPE2(2) = 1;
                end
            else
                perfectRPE2(1) = 0;
                perfectRPE2(2) = 0;
            end         
        end
    end
    
    a = [meanOMShortSpikes(2)-meanSpikes(1), meanSpikes(1)-meanSpikes(3),...
    meanSpikes(3)-meanSpikes(2)];
    if (all(a>0)||all(a<0))&&(sig0vs50om<0.05)&&(sig0vs50om<0.05)
        perfectRPE1(1) = 1;
        if all(a>0)
            perfectRPE1(2) = -1;
        else
            perfectRPE1(2) = 1;
        end
    else
        perfectRPE1(1) = 0;
        perfectRPE1(2) = 0;
    end  
a = [csValue',delayValue',EarlydelayValue',usExpectation',usReward',om',usRPE1',usRPE2',perfectRPE1',perfectRPE2'];
newCodingResults = array2table(a,'VariableNames',{'csValue','delayValue','EarlydelayValue','usExpectation','usReward',...
    'om','usRPE1','usRPE2','perfectRPE1','perfectRPE2'},'RowNames',{'Sig','Dir'});
if saveFlag
    save(fn,'-append','newCodingResults');
end

end