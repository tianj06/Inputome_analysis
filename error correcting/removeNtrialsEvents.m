function events = removeNtrialsEvents(events,n)
    events.odorOn =  events.odorOn(n+1:end);
    events.odorOff = events.odorOff(n+1:end);  
    events.odorID = events.odorID(n+1:end); 
    events.laserOn = events.laserOn(n+1:end); 
    events.laserOff = events.laserOff(n+1:end); 
    events.rewardOn = events.rewardOn(n+1:end);
    events.airpuffOn = events.airpuffOn(n+1:end);  
    events.leverOn = events.leverOn(n+1:end); 
    events.firstLick = events.firstLick(n+1:end);  
    events.trialType = events.trialType(n+1:end); 
end