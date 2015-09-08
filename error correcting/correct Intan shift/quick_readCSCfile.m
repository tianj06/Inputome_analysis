function [filtWV, ts, chunkSize, sampfreq] = quick_readCSCfile(CSCfile, record_range)
% read CSCfile
% extract filtered waveform, and sampling frequency
% 
if isstr(CSCfile)
    if  strcmp(CSCfile(end-2:end), 'ncs')
        intan = 0;
    elseif strcmp(CSCfile(end-2:end), 'dat')
        intan = 1;
    else
        error('unknown file type')
    end
else
    intan=1; % so far only CSCtoMatIntan support file ID as input
end


N = size(record_range,1);
timestamps = cell(N,1); 
WV = cell(1,N);
if intan
    [timestamps,sampfreq, WV] = CSCtoMatIntan(CSCfile, record_range,1);
    WV = WV';
else
    for i = 1:size(record_range,1)
            [timestamps{i}, sampfreq, WV{i}] = Nlx2MatCSC(CSCfile, [1 0 1 0 1], 0, 2, ...
                record_range(i,:)); %multiplying by 1000 converts to us for neurlynx
            if (sampfreq(1)==0)||(length(timestamps{i})==1)
                 [ts, sf,wv] = Nlx2MatCSC(CSCfile, [1 0 1 0 1], 0, 1); % extract all 
                 if ~isempty(find(ts> record_range(i,2)*1000,1,'first'))
                     idx(1) = find(ts> record_range(i,1)*1000,1,'first')-1;
                     idx(2) = find(ts> record_range(i,2)*1000,1,'first');
                     timestamps{i} = ts(idx(1):idx(2));
                     WV{i} = wv(:,idx(1):idx(2));
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
ts = cell2mat(timestamps);
ts = reshape(ts,1,[]);
if ~intan
    WV = 0.0305.*WV;  % convert to uV unit - this is per Ju's code
end
    

c=1;
if intan
    chunkSize = 1000;  % number of data points per timestamp
else
    chunkSize = 512;
end


%% filter the waveforms
% for now just use Ju's lowpass_signal.m and highpass_signal.m, which uses
% 5th order and 10th order butterworth filters, respectively.
filtWV = lowpass_signal(WV,sampfreq,9000);
filtWV = highpass_signal(filtWV,sampfreq,300);