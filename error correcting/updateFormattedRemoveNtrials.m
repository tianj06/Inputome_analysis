function updateFormattedRemoveNtrials(fn,n)
    load(fn,'events')
    events = removeNtrialsEvents(events,n);
    save(fn,'events','-append');
    analyzedData = getPSTHSingleUnit(fn);
    save(fn,'analyzedData','-append')
end