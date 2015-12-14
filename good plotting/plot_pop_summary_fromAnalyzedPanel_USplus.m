function plot_pop_summary_fromAnalyzedPanel_USplus(fl,savePath,figureName)
    if nargin<3
        figureName = 'temp';
        if nargin<2
            savePath = 'D:\Dropbox (Uchida Lab)\lab\FunInputome\rabies\allIdentified\Analysis\psthPlottings\';
        end
    end
    psthAll = [];
    auROCall = [];
    k = 1;
    for i = 1:length(fl)
        load(fl{i},'analyzedData')
        analyzedData = remove_too_few_trials(analyzedData,minTrialNum);
        if ~isnan(analyzedData.rocPSTH(:,5)) 
            psthAll(k,:,:) = analyzedData.smoothPSTH;
            auROCall(k,:,:) = analyzedData.rocPSTH;
            k = k+1;
        end
    end
    
    totalFile = length(fl);
    colNum = 4;
    rowNum = 4;
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
    end
    set(gcf, 'Units', 'Inches', 'Position', [0, 0, 10, 8], 'PaperUnits', 'Inches', 'PaperSize', [11 8.5])
    export_fig([savePath  figureName num2str(pageIdx) '.jpg'])
end