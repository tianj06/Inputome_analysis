function fitSpikesByValue(fn)
    load(fn)
    triggerCS = { events.odorOn(ismember(events.trialType,[1,2]))
        events.odorOn(ismember(events.trialType,[3,4]))
        events.odorOn(ismember(events.trialType,[5,6]))
        events.odorOn(ismember(events.trialType,[7,8]))};
        
    [~,r,~] = plotPSTH(responses.spike,triggerCS, 1000, ...
    4000, 'plottype','none', 'smooth','n');

    X = [3*ones(length(triggerCS{1}),1) 
        2*ones(length(triggerCS{2}),1) 
        1*ones(length(triggerCS{3}),1)]; 
    y = [];
    for j = 1:3
        y = [y ; mean(r{j}(:,1000:1500),2) ]; %- mean(r{j}(:,500:1000),2)
    end
    y = y*1000;
    mdl1 = fitglm(X,y,'distribution','poisson')
    mdl1.Rsquared
    mdl2 = fitglm(X,y,'distribution','normal')
    mdl2.Rsquared

 quickPSTHPlotting_formatted(fn)