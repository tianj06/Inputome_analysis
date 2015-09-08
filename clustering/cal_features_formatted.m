function r_output = cal_all_features_formatted(fileName, FeatureType,TriggerType)
% filename: formatted data name
% FeatureType: 'fr', firing rate, baseline subtracted;
%                     'nmfr': normalized firing rate;
%                     'auroc', auROC vs baseline;
% TriggerType
load(fileName)
% ttCwaterUwater = 1;
% ttCwaterUnothing = 2;
% ttCuncertainUwater = 3;
% ttCuncertainUnothing = 4;
% ttCnothingUwater = 5;
% ttCnothingUnothing = 6;
% ttCairpuffUairpuff = 7;
% ttCairpuffUnothing = 8;
% ttUwater = 9;
% ttUairpuff = 10;
%

if nargin ==2
    TriggerType ={ 'odor','delay','reward','airpuff','omission' };
elseif nargin ==1
    FeatureType = 'fr';
    TriggerType = { 'odor','delay','reward','airpuff','omission' };
end
%%
    OdorTrig = {events.odorOn(events.odorID == 3) % high prob reward cue
        events.odorOn(events.odorID == 1) % 50% prob cue
        events.odorOn(events.odorID == 2) % 10% prob cue
        events.odorOn(events.odorID == 4) % airpuff cue
        };
     DelayTrig = {events.odorOn(events.odorID == 3) % high prob reward cue
        events.odorOn(events.odorID == 1) % 50% prob cue
        events.odorOn(events.odorID == 2) % 10% prob cue
        events.odorOn(events.odorID == 4) % airpuff cue
        };
    RewardTrig = {
        events.rewardOn(events.trialType == 1) % 90% reward
        events.rewardOn(events.trialType == 3) % 50% reward
        events.rewardOn(events.trialType == 5) % 10% reward
        events.rewardOn(events.trialType == 9)% free reward
         };        
     AirpuffTrig = {
        events.airpuffOn(events.trialType == 7) % predicted airpuff 
        events.airpuffOn(events.trialType == 10) % free airpuff 
        };
    OmissionTrig = {
        events.odorOn(events.trialType == 2)+2000 % 90 omission
        events.odorOn(events.trialType == 4)+2000 % 50 omission
        events.odorOn(events.trialType == 6)+2000 % 10 omission
        events.odorOn(events.trialType == 8)+2000 % airpuff omission 
        };
   
      [~, bt] = plotPSTH(responses.spike, OdorTrig, 1000, 0, ...
          'plotflag', 'none','smooth','n');
     allBaseline = [];
     for i = 1: length(bt)
         allBaseline = [allBaseline; sum(bt{i},2)];
     end

     r_output = cell(1,length(TriggerType));
 for j = 1:length(TriggerType)   
     if strfind(TriggerType{j},'odor')
         Trig = OdorTrig;
         preTime = 1000;
         postTime = 500;
         baseWin = [1:1000];
         ResWin = [1001:1500];
     elseif strfind(TriggerType{j},'delay')
         Trig = OdorTrig;
         preTime = 1000;
         postTime = 2000;
         baseWin = [1:1000];
         ResWin = [2001:3000];
     elseif strfind(TriggerType{j},'reward')
         Trig = RewardTrig;
         preTime = 3000;
         postTime = 500;
         baseWin = [1:1000];
         ResWin = [preTime+1:preTime+500];
     elseif strfind(TriggerType{j},'airpuff')
         Trig = AirpuffTrig;   
         PreTime = 3000;
         postTime = 500;
         baseWin = [1:1000];
         ResWin = [preTime+1:preTime+500];
     elseif strfind(TriggerType{j},'om')
         Trig = OmissionTrig;   
         PreTime = 3000;
         postTime = 500;
         baseWin = [1:1000];
         ResWin = [preTime+1:preTime+500];
     end
     

     
      [~, R] = plotPSTH(responses.spike, Trig, preTime, postTime, ...
          'plotflag', 'none','smooth','n');
      if strcmp(FeatureType(1),'f' )
          for i = 1:length(R)
                r = mean(mean(R{i}(:,ResWin)*1000,2));
                b = mean(mean(R{i}(:,baseWin)*1000,2));
                if length(R{i})<20
                    b = mean(allBaseline);
                end
                r_output{j}(i) =  r - b;
          end
      elseif strcmp(FeatureType(1),'n' )
          for i = 1:length(R)
                r = mean(mean(R{i}(:,ResWin)*1000,2));
                b = mean(mean(R{i}(:,baseWin)*1000,2));
                if length(R{i})<20
                    b = mean(allBaseline);
                end
                r_output{j}(i) = (r - b)/b;
          end 
      elseif strcmp(FeatureType(1),'a' )
          for i = 1:length(R)
                r = mean(R{i}(:,ResWin)*1000,2);
                b = mean(R{i}(:,baseWin)*1000,2);
                if length(R{i})<20
                    b = allBaseline;
                end
                r_output{j}(i) = auROC(r,b);
          end   
      end
 end
  
  

end