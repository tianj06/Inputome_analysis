function [s_psth, sd_psth] = getSmoothedPSTHwithSD(y, method, param)
% SMOOTHPSTH: z = smoothPSTH(y, method, param)
%  smoothPSTH applies one of several smoothing filters onto the input
%  Input:
%   y: vector or matrix or cell array.  Applies smoothing across _ROWS_.
%   method/param: 
%    - 'box' implements boxcar, param = width of boxcar
%    - 'gaussian' implements gaussian filter, param = std
%    - 'psp' implements post-synaptic potential shaped filter, param = tau
%       FYI: psp filter = ( 1-e^-(1:n) ) / e^(-(1:n)/tau)
%  Output:
%   z: vector or matrix, same dimensions as y

% Ju modified from Vinod Rao's smoothPSTH 

if nargin < 2
    error('Insufficient param: please specify data and a method');
end

cellflag = iscell(y);
if cellflag    % this handles the cell arrays using recursion
    if length(y)==1
        y = y{1};
    else
        z = cat(1,{smoothPSTH(y{1}, method, param)},smoothPSTH(y(2:end),method,param));
        return;
    end
end
   
z = zeros(size(y));

switch lower(method)
    case 'box'
        if isempty(param) || numel(param) ~= 1
            error('Box method requires a parameter indicating the box width');
        end
        for i = 1:size(y,1)
            z(i,:) = smooth(y(i,:),param);
        end
        
    case 'gaussian'
        if isempty(param) || numel(param) ~= 1
            error('Gaussian method requires a parameter indicating the Gaussian width');
        end
        sm_filt = normpdf(-2*param:2*param, 0, param); %filter is +/- 2 s.d.'s
        sm_filt = sm_filt./sum(sm_filt);
        for i = 1:size(y,1)
            temp = conv(y(i,:),sm_filt); %this smooths but adds half the filter width per side
            temp = temp ./ sum(temp) .* sum(y(i,:)); %assure normalization
            z(i,:) = temp(2*param+1:end-2*param); %trims off the extra 2 s.d.'s
        end
        
    case 'psp'
        if nargin == 2
            param = 20; %default is 20ms only if time unit is in ms
        elseif length(param) ~= 1 || numel(param) ~= 1
            error('PSP method takes only a single parameter indicating the time constant, tau');
        end
        tau = param; n = 4*param; 
        sm_filt = (1-exp(-(1:n))).* exp((1:n)/-tau);
        sm_filt = sm_filt./sum(sm_filt);
        for i = 1:size(y,1)
            temp = conv(y(i,:),sm_filt); %this smooths but adds half the filter width per side
            temp = temp ./ sum(temp) .* sum(y(i,:)); %assure normalization
            z(i,:) = temp(1:length(temp)-n+1); %trims off the extra half-filter
        end
        
    otherwise
        error('Invalid choice of method.');
end

if cellflag
    z = {z};
end
        
end

