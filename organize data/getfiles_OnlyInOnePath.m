function fl = getfiles_OnlyInOnePath(path1,path2)
fl1 = what(path1);
fl1 = fl1.mat;
fl2 = what(path2);
fl2 = fl2.mat;
idx = ismember(fl1,fl2);
fl = fl1(~idx);