function cValue = loadValueforClustering(filelist,Type)
    if Type ==1
        for i = 1:length(filelist)
            r_out = cal_features_formatted(filelist{i},'a');
            cValue(i,:) = cell2mat(r_out);
        end
    elseif Type ==2
        pretrigger = 1000;
        posttrigger = 4000;
        rocBin = 100;
        binNum = (pretrigger + posttrigger)/rocBin;
        auROCvalue = zeros(3,length(filelist),binNum);
        psthValue = zeros(3,length(filelist),5001);
        for i = 1:length(filelist)
            load(filelist{i})
            trigger = {events.odorOn(events.trialType==1)
                events.odorOn(events.trialType==6)
                events.odorOn(events.trialType==7)}; % 90% reward
             [~, r, psths] = plotPSTH(responses.spike, trigger, pretrigger, posttrigger, ...
                  'plotflag', 'none');
             % calculate roc
             psthValue(:,i,:) = psths;
             for j = 1:3
                 baseline = [];
                 for n = 1:pretrigger/rocBin
                     if j==4
                         temp = sum(r{1}(:,rocBin*(n-1)+1:rocBin*n),2);
                     else
                         temp = sum(r{j}(:,rocBin*(n-1)+1:rocBin*n),2);
                     end
                    baseline = [baseline; temp];
                end

                for k = 1:binNum
                    s = sum(r{j}(:,rocBin*(k-1)+1:rocBin*k),2);
                    auROCvalue(j,i,k) = auROC(s,baseline);
                end
             end
        end
        cValue = auROCvalue;
        
    end
end


