function  [p_reg, R2, p_corr_all] = computeValueSig(r, x)
     if isempty(find(cellfun(@isempty,r)))
         binmean = cellfun(@mean,r);
         meanModelL = fitlm(x,binmean,'linear');
         R2 = meanModelL.Rsquared.Ordinary;
        [x, y] = convertRegress(r, x);
        modelL = fitlm(x,y,'linear');
        p_reg = coefTest(modelL);
        %R2 = modelL.Rsquared.Ordinary;
         [p_corr_all, ~] = corr(x,y);

        % correlation analysis to check value coding
     else
         p_reg = nan;
         p_corr_all = nan;
         R2 = nan;
     end