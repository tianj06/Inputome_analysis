function plot_pop_summary_fromAnalyzedPanel(fl,savePath,figureName)
    if nargin<3
        figureName = 'temp';
        if nargin<2
            savePath = 'D:\Dropbox (Uchida Lab)\lab\FunInputome\rabies\allIdentified\Analysis\psthPlottings\';
        end
    end
    psthAll = [];
    auROCall = [];
    for i = 1:length(fl)
        load(fl{i},'analyzedData')
        psthAll(i,:,:) = analyzedData.smoothPSTH;
        auROCall(i,:,:) = analyzedData.rocPSTH;
    end
    
    totalFile = length(fl);
    colNum = 4;
    rowNum = 2;
    pagePicNum = colNum*rowNum;
    % color for 90% water, 50% water, nothing, and airpuff; will modify later
    colorSet = [0 	0 	255;%blue  
                   30 	144 	255;%light blue  
                   %128 	128 128; % grey
                    0 0 0]/255; % black;
    for n = 1:totalFile
        load(fl{n},'lightResult')
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
        p(rowIdx,colIdx).pack('v',2)
        p(rowIdx,colIdx,1).select()
        plotTrialType = [1 2 9];
        for i = 1:length(plotTrialType)
            plot(-1:0.001:4,squeeze(psthAll(n,plotTrialType(i),:)),'color',colorSet(i,:)); hold on;
            xlim([-0.9 3.9])
            yL = ylim;
            if i==2
                if rowIdx == 1
                    text(-0.9,yL(2)*0.8,fl{n}(1:end-14))
                else
                    title(fl{n}(1:end-14))
                end
            end
        end
        
        p(rowIdx,colIdx,2).select()
        plotTrialType = [5:7];
        for i = 1:length(plotTrialType)
            plot(-1:0.001:4,squeeze(psthAll(n,plotTrialType(i),:)),'color',colorSet(i,:)); hold on;
            xlim([-0.9 3.9])
            %title(['lowP=' num2str(lightResult.lowSaltP,3) ' highP=' num2str(lightResult.highSaltP,3)])
        end
    end
    set(gcf, 'Units', 'Inches', 'Position', [0, 0, 10, 8], 'PaperUnits', 'Inches', 'PaperSize', [11 8.5])
    export_fig([savePath  figureName num2str(pageIdx) '.jpg'])
end