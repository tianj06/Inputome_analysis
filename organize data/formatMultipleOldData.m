%formatMultipleOldData
for i = 10:31
    cd(strjoin(fileList(i,1:2),'\'))
    formatNlynxCCtaskDataMitsukoEarly(pwd,[fileList{i,3} '.t'])
end
