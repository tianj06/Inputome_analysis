function [DelayValue TimeShift RawWV] = alignSpikesCSCfile(ST, CSCfile,refOn)
if nargin <3
    refOn = 0;
end
%CSCfile = 'L:\VP\Dimsum\2014-11-08_14-19-06\CSC24.ncs';
fr = round(1000*length(ST)/(ST(end)-ST(1)));
N = 100;
cscWindow = [ST(2*fr+1) ST(N+2*fr)]% [ST(2*fr+1) ST(N+2*fr)];
if ~isempty(find(ST==0,1))
    ST(ST==0) = [];
end
if refOn
    [filtWV, intTS, sampfreq] = readCSCfile(CSCfile{1}, cscWindow);
    [refdata, intTS, sampfreq] = readCSCfile(CSCfile{2}, cscWindow);
    filtWV = filtWV - refdata;
else
    [filtWV, intTS, sampfreq] = readCSCfile(CSCfile, cscWindow);
end
ind1 = find(ST>intTS(1),1,'first');
ind2 = find(ST<intTS(end),1,'last');
tempTTspike = ST(ind1:ind2);% timestamp of clustered spikes
preSpike = find(intTS<tempTTspike(1),1,'last');
postSpike = find(intTS>tempTTspike(end),1,'first');
tempCSC = filtWV(preSpike:postSpike);
tempTS = intTS(preSpike:postSpike);
% extract all potential cross threshold events in CSC file
k = 5;
thresh = k*std(filtWV); %this includes the actual spikes so this should be well above baseline
idx = sort([crossing(tempCSC-thresh)  crossing(tempCSC+thresh)]);% timestamp index of crossing threshold events
while( length(idx)<200)
    k = k-1;
    thresh =k*std(filtWV); 
    idx = sort([crossing(tempCSC-thresh)  crossing(tempCSC+thresh)]);
end

%%
CSCspike = tempTS(idx); % timestamp of crossing threshold events
% vary the spike delay to minimize the distance between potential spikes
% and clustered spikes


t0 = min(CSCspike(1),tempTTspike(1)); 
CSCspikeRd = unique(round(10*(CSCspike - t0)));  % 0.1ms as unit
CSCspikeRd = CSCspikeRd(find(CSCspikeRd)); % remove 0
tempTTspikeRd = round(10*(tempTTspike - t0));
tempTTspikeRd = tempTTspikeRd(find(tempTTspikeRd));
maxI = max(CSCspikeRd(end), tempTTspikeRd(end));
tempCSCSpikeTrace = zeros(1,maxI);
tempCSCSpikeTrace (CSCspikeRd) = 1;
tempTTtrace =  zeros(1,maxI); 
tempTTtrace(tempTTspikeRd) = 1;
[xcf, lags, bounds] = crosscorr(tempCSCSpikeTrace,tempTTtrace,100,3);
[~,TimeShift] = max(xcf);
TimeShift = lags(TimeShift)*0.1;  %ms, positive Timeshift meaning the TT ts is bigger than CSC
if abs(TimeShift)>5
    error('could be an error in aligning CSC file and clustered timestamp')
end
display(['Timeshift of TT is' num2str(TimeShift)])
DelayValue = 0;
RawWV = nan(length(tempTTspike),32);
for i = 1:length(tempTTspike)
    s = tempTTspike(i) - TimeShift;
    [DelayValue(i), ind] = min(abs(s-CSCspike));
    cscInd = find(tempTS ==CSCspike(ind));
    if (cscInd-15 > 1)&&(cscInd+16<length(tempCSC))
        RawWV(i,:) = tempCSC(cscInd-15: cscInd+16);
    end
end

if median(DelayValue)>0.5
    error('could be an error in aligning CSC file and clustered timestamp')
end
%% debug time alignment problem
%first plot the rawtrace with cross threshold events marked
%  figure; 
%  plot(tempTS,tempCSC)
%  hold on; scatter(CSCspike,thresh*ones(1,length(CSCspike)))
% % plot the clustered timestamps with the timeshift
%  scatter(tempTTspike-TimeShift,thresh*ones(1,length(tempTTspike)),'k')
%  legend('rawCon','rawCrossThres','spikeTS')
