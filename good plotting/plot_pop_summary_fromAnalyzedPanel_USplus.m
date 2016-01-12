function plot_pop_summary_fromAnalyzedPanel_USplus(fl,savePath,figureName,colNum)
if nargin < 4
    colNum = 4;
    if nargin<3
        figureName = 'temp';
        if nargin<2
            savePath = 'D:\Dropbox (Uchida Lab)\lab\FunInputome\rabies\allIdentified\Analysis\psthPlottings\';
        end
    end
end
    psthAll = [];
    auROCall = [];
    for i = 1:length(fl)
        load(fl{i},'analyzedData')
        psthAll(i,:,:) = analyzedData.smoothPSTH(1:10,:);
        auROCall(i,:,:) = analyzedData.rocPSTH(1:10,:);
    end
    
    totalFile = length(fl);
    rowNum = 5;
    pagePicNum = colNum*rowNum;
    % color for 90% water, 50% water, nothing, and airpuff; will modify later
    colorSet = [0 	0 	255;%blue  
                   30 	144 	255;%light blue  
                   128 	128 128; % grey
                   %255 0 0
                   ]/255; % black;
    for n = 1:totalFile
        pageIdx = floor((n-1)/pagePicNum)+1;
        tempn = n-(pageIdx-1)*pagePicNum;

        if (mod(n,pagePicNum)==1)
            if pageIdx>1
                set(gcf, 'Units', 'Inches', 'Position', [0, 0, 11, 8.5], 'PaperUnits', 'Inches', 'PaperSize', [11 8.5])
                export_fig([savePath  figureName num2str(pageIdx-1) '.jpg'])
            end
            figure;
            p = panel();
            p.pack(rowNum,colNum)
        end
        colIdx = mod(tempn-1,colNum)+1;
        rowIdx = floor((tempn-1)/colNum)+1;
        p(rowIdx,colIdx).select()
        
        plotTrialType = [1 2 7];
        for i = 1:length(plotTrialType)
            plot(-1:0.001:4,smooth(squeeze(psthAll(n,plotTrialType(i),:)),10),'color',colorSet(i,:)); hold on;
            xlim([-0.9 3.9])
            yL = ylim;
            [animalName, folderName, unitName] = extractAnimalFolderFromFormatted(fl{n});
            mdate = folderName(6:10);
            titleText = [animalName mdate unitName];
            if i==2
                title(titleText)
            end
        end 
        set(gca,'Box','off')
        set(gca,'TickDir','out')
        set(gca,'TickLength',[0.02 0.025])
    end
    set(gcf, 'Units', 'Inches', 'Position', [0, 0, 10, 8], 'PaperUnits', 'Inches', 'PaperSize', [11 8.5])
    export_fig([savePath  figureName num2str(pageIdx) '.jpg'])
end