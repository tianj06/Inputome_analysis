function renameTrialType(fn)
% Ju trialType for habenula lesion projects

% 1   90% reward ->1
% 2  50% reward ->3
% 3  10% reward -> 5
% 4  free reward -> 9
% 5  no reward -> 6
% 6 50% reward omission -> 4
% 7 10% reward omission -> 2
% 8  80% airpuff -> 7
% 9 free airpuff -> 10
% 10 20% airpuff omission ->8

% Ju trialType for inputome project

% ttCwaterUwater = 1;
% ttCwaterUnothing = 2;
% ttCuncertainUwater = 3;
% ttCuncertainUnothing = 4;
% ttCnothingUwater = 5;
% ttCnothingUnothing = 6;
% ttCairpuffUairpuff = 7;
% ttCairpuffUnothing = 8;
% ttUwater = 9;
% ttUairpuff = 10;

load(fn)

for i = 1:10
    oldtrialType{i} = find(events.trialType==i);
end

newTrialType = [1 3 5 9 6 4 2 7 10 8];
for i = 1:10
    events.trialType(oldtrialType{i}) = newTrialType(i);
end

save(fn,'-append','events');