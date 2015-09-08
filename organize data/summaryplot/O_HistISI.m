function [H, binsUsed] = HistISI(T, axesHandle)

% H = HistISI(TS, parameters)
%  H = HistISI(TS, 'maxLogISI','maxLogISI',5)      for fixed upper limit 10^5 msec (or 100 sec)
%
% INPUTS:
%      TS = a single ts object
%
% OUTPUTS:
%      H = histogram of ISI
%      N = bin centers
%
% PARAMETERS:
%     nBins 500
%     maxLogISI variable
%     minLogISI 
%--------------------
epsilon = 1e-100;
nBins = 500;
maxLogISI = 3;
minLogISI = -3;
if nargin <2
    axesHandle = gca;
end
myTitle = '';
myFigureTag = 'HistISI';
myColor = 'b';

binsUsed = nan; H = nan;
ISI = diff(T) + epsilon;
if isempty(ISI)
   warning('MClust:ISI','ISI contains no data!');
   return
end   
if ~isreal(log10(ISI))
   warning('MClust:ISI', 'ISI contains negative differences; log10(ISI) is complex.');
   complexISIs = true;
else
   complexISIs = false;
end

if isempty(maxLogISI)
    maxLogISI = max(real(log10(ISI)))+1;     
end

if isempty(minLogISI)
    minLogISI = min(real(log10(ISI)));
end

binsUsed = linspace(minLogISI,maxLogISI,nBins);
H = histcn(log10(ISI)+eps, binsUsed);

%-------------------
if nargout == 0 || ~isempty(axesHandle)  % no output args, plot it
    if isempty(axesHandle)
        axesHandle = axes('Parent', figure('Tag', myFigureTag));
    end
    plot(axesHandle, binsUsed, H, '-', 'color', myColor); hold on
    plot([-3 -3], get(axesHandle, 'yLim'), 'r-', ...
        [log10(0.002) log10(0.002)], get(axesHandle, 'yLim'), 'g-');
    hold off
    if complexISIs
        xlabel('ISI (s).  WARNING: contains negative components.');
    else
        xlabel('ISI (log10(s)).');
    end
    title(myTitle);
    set(gca, 'XLim', [minLogISI maxLogISI]);
    if sum(ISI<0.002)>0
        text(min(get(axesHandle,'xLim')), max(get(axesHandle, 'yLim')), ...
            sprintf(' %d ISIs<2ms', sum(ISI<0.002)), ...
            'VerticalAlignment','top','HorizontalAlignment','left');
    end        
    set(gca, 'YTick', max(H));    
end
   


   