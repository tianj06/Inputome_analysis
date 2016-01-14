function l = freeUSlatency(r,timeWindow,step,bin)
    resOffset = 3000;
    p_binWin = [];
%     r1 = r(:,resOffset-500:resOffset-1); % preUS period
%     N = 500/bin;
%     bw = mean(reshape(r1,[],bin,N),2);
%     bw = reshape(bw,1,[]);
    bw = mean(r(:,resOffset-bin:resOffset-1),2);
    N_step = timeWindow/step;
    for k = 1:N_step
        tw = resOffset + (step*(k-1)+1:step*(k-1)+bin);
        rw = mean(r(:,tw),2);
        p_binWin(k) = signrank(rw,bw);
    end
    ind = strfind(p_binWin<0.05,[1 1 1 1 1]); %1 1 1 1 1
    if ~isempty(ind)
        l = (ind(1)-1)*step+0.5*bin;
    else
        l = nan;
    end