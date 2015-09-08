for i = 1:length(flall)
    clear checkLaser
    load(flall{i})
    if exist('checkLaser','var')
        if ~isfield(checkLaser,'p_inhibit')
             trigger = events.freeLaserOn;
             [~, r, ~] = plotPSTH(responses.spike, trigger, 20, 20, ...
              'plotflag', 'none','smooth','n');
            checkLaser.p_inhibit = signrank(sum(r{1}(:,11:20),2), sum(r{1}(:,21:30),2),'tail','right' );
            save(flall{i},'-append','checkLaser') 
        end
    end
end