function [filtWV, intTS, sampfreq] = readCSCfile(CSCfile, timeWin,filterFlag)
% read CSCfile and return interploted timestamps
% filtered waveform, and sampling frequency
% readCSCfile(CSCfile, timeWin)
% input timeWin = [start1 stop1;
%                            start2 stop2] %ms

if nargin<3
    filterFlag = 1;
end
if  strcmp(CSCfile(end-2:end), 'ncs')
    intan = 0;
elseif strcmp(CSCfile(end-2:end), 'dat')
    intan = 1;
else
    error('unknown file type')
end

if nargin ==1
    timeWin = nan;
end

N = size(timeWin,1);
timestamps = cell(N,1); 
WV = cell(1,N);
if intan
    [timestamps,sampfreq, WV] = CSCtoMatIntan(CSCfile, timeWin*10);
    WV = WV';
else
    for i = 1:size(timeWin,1)
        if isnan(timeWin(1))
             [timestamps{i}, sampfreq, WV{i}] = Nlx2MatCSC(CSCfile, [1 0 1 0 1], 0, 1);
        else
            [timestamps{i}, sampfreq, WV{i}] = Nlx2MatCSC(CSCfile, [1 0 1 0 1], 0, 4, ...
                timeWin(i,:)*1000); %multiplying by 1000 converts to us for neurlynx
            if (sampfreq(1)==0)||(length(timestamps{i})==1)
                 [ts, sf,wv] = Nlx2MatCSC(CSCfile, [1 0 1 0 1], 0, 1); % extract all 
                 if ~isempty(find(ts> timeWin(i,2)*1000,1,'first'))
                     idx(1) = find(ts> timeWin(i,1)*1000,1,'first')-1;
                     idx(2) = find(ts> timeWin(i,2)*1000,1,'first');
                     timestamps{i} = ts(idx(1):idx(2));
                     WV{i} = wv(:,idx(1):idx(2));
                 end
            end
        end
    end
    if sampfreq == 0
        sampfreq = sf;
    end
end
sampfreq = sampfreq(1); %samples per second
WV = cell2mat(WV);
WV = reshape(WV,1,[]);
if ~intan
    WV = 0.0305.*WV;  % convert to uV unit - this is per Ju's code
end
    
intTS = nan(size(WV));
c=1;
if intan
    chunkSize = 1000;  % number of data points per timestamp
else
    chunkSize = 512;
end

for j = 1:length(timestamps)
    for i = 1:length(timestamps{j})
        if i~=length(timestamps{j})
            temp = linspace(timestamps{j}(i),timestamps{j}(i+1),chunkSize+1);
            intTS(c:c+chunkSize-1) = temp(1:end-1);
        else %last block needs to extrapolate
            extrapTS = timestamps{j}(end)+diff(timestamps{j}(end-1:end));
            temp = linspace(timestamps{j}(i),extrapTS,chunkSize);
            intTS(c:c+chunkSize-1) = temp(1:end);
        end
        c = c+chunkSize;
    end
end
if intan
    intTS = intTS/10;
else
    intTS = intTS/1000;
end
clear timestamps
%% filter the waveforms
% for now just use Ju's lowpass_signal.m and highpass_signal.m, which uses
% 5th order and 10th order butterworth filters, respectively.
if filterFlag
    filtWV = lowpass_signal(WV,sampfreq,9000);
    filtWV = highpass_signal(filtWV,sampfreq,300);
else
    filtWV = WV;
end
%filtWV = WV;