figlists = rdir(['D:\Dropbox (Uchida Lab)\lab\FunInputome\PlottingByTetrode\*\*\*.fig']);
for i = 450:length(figlists)
    figname = figlists(i).name;
    [a,name,~] = fileparts(figname);
    newFilename = [figname(1:end-4) '.jpg'];
    if ~exist(newFilename,'file')
        openfig(figname,'new','invisible')
        saveas(gcf,newFilename)
        close all
    end
end