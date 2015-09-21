function CompuateResponsiveNeurons(fn,saveFlag)
if nargin <2
    saveFlag = 1;
end
    %fn = 'Biscuit_2014-11-08_18-22-38_TT7_01_formatted.mat';
    load(fn,'analyzedData');
    rs = analyzedData.raster;    
    
%% CS responsive neurons; ANOVA 0 50 90 significant
    mergeCellTypes = @(A,B)([A;B]);
    crs = cellfun(mergeCellTypes, rs(1:4), rs(5:8),'UniformOutput',0);

    TimeWin = [1:500];
      
    % extract CS response (subtract by iti baseline)
    CS_spikes = cellfun(@(x)1000*mean(x(:,TimeWin+1000),2)-1000*mean(x(:,1001-TimeWin),2),crs(1:3),'UniformOutput',0);
    delay_spikes = cellfun( @(x)1000*mean(x(:,3000-TimeWin),2)-1000*mean(x(:,1001-TimeWin),2),crs(1:3),'UniformOutput',0);
    Early_delay_spikes = cellfun( @(x)1000*mean(x(:,2500-TimeWin),2)-1000*mean(x(:,1001-TimeWin),2),crs(1:3),'UniformOutput',0);

    CSresponse = [];
    Delay_response = [];
    Early_delay_response = [];
    trialGroup = [];
    for i = 1:length(CS_spikes)
        CSresponse = [CSresponse; CS_spikes{i}];
        Delay_response = [Delay_response; delay_spikes{i}];
        Early_delay_response = [Early_delay_response; Early_delay_spikes{i}];
        trialGroup = [trialGroup; i*ones(length(CS_spikes{i}),1)];
    end
    CSsig = anova1(CSresponse, trialGroup, 'off');
    if CSsig < 0.05
        CSsig = 1;
    else
        CSsig = 0;
    end
    
    Expsig = anova1(Delay_response, trialGroup, 'off');
    if Expsig < 0.05
        Expsig = 1;
    else
        Expsig = 0;
    end    
    
    Early_delay_sig = anova1(Early_delay_response, trialGroup, 'off');      
    if Early_delay_sig < 0.05
        Early_delay_sig = 1;
    else
        Early_delay_sig = 0;
    end
    
    
 %% Reward response
    urs = rs([7 1 2 ]); %   90 reward,50 reward, free reward 
    US_spikes = cellfun(@(x)1000*mean(x(:,TimeWin+3000),2)-1000*mean(x(:,3001-TimeWin),2),urs,'UniformOutput',0);

    Om50 = 1000*mean(rs{6}(:,TimeWin+3000),2)-1000*mean(rs{6}(:,3001-TimeWin),2);
    [~,Sig50Rewardvs50OM] = ranksum(Om50,US_spikes{2});
    a  = [CSsig, Expsig,Sig50Rewardvs50OM,Early_delay_sig];   
    EventSig = array2table(a,'VariableNames',{'CSsig','Expsig','Rewardsig','EarlyExpsig'});
    if saveFlag
        save(fn,'-append','EventSig');
    end

end