function [shiftMode, IdxLag, RMScorr, stepSize] = intan_csc_shift_mode_cal(allChipsFileName,...
    chip1FileName,chip2FileName,recordNum,offset)
if nargin<5
    offset = 0;
end
offset = round(offset);    
Nblock = 10;
stepSize = floor((recordNum-50-offset)/Nblock);
IdxLag = zeros(1,Nblock-1);
RMScorr = zeros(1,Nblock-1);
for i = 1:Nblock-1
    [IdxLag(i), RMScorr(i)]= calculate_channeldx_shift(allChipsFileName, [1 stepSize*i+offset], 50);
end

if mean(RMScorr) > 0.8
    IdxLag = [0 IdxLag];
    RMScorr = [1 RMScorr];
    shiftMode = 1;
else  
    IdxLagChip1 = zeros(1,Nblock-1);
    RMScorrChip1 = zeros(1,Nblock-1);
    for i = 1:Nblock-1
        [IdxLagChip1(i) RMScorrChip1(i)]= calculate_channeldx_shift(chip1FileName, [1+offset stepSize*i+offset], 50);
    end
    IdxLagChip2 = zeros(1,Nblock-1);
    RMScorrChip2 = zeros(1,Nblock-1);
    for i = 1:Nblock-1
        [IdxLagChip2(i) RMScorrChip2(i)]= calculate_channeldx_shift(chip2FileName, [1+offset stepSize*i+offset], 50);
    end   

    if mean(RMScorrChip1)>0.9 && mean(RMScorrChip2)>0.9
        IdxLag = [0 IdxLagChip1;0 IdxLagChip2];
        RMScorr = [1 RMScorrChip1; 1 RMScorrChip2];
        shiftMode = 4;
    elseif mean(RMScorrChip1)>0.9
        IdxLag = [0 IdxLagChip1];
        RMScorr = [1 RMScorrChip1];
        shiftMode = 2;
    elseif mean(RMScorrChip2)>0.90
         IdxLag = [0 IdxLagChip2];
         RMScorr = [1 RMScorrChip2];
         shiftMode = 3;
    else
        error('none of the common shift explains the data')
    end
    end
end
