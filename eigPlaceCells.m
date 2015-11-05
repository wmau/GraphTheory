function eigPlaceCells(A,sessionStruct,bootstrap)
%
%
%

%% 
    %Get filepath.
    path = sessionStruct.Location; 
    
    %Load place field data. 
    load(fullfile(path,'PlaceMaps.mat'),'pval'); 
     
    %Get indices of place cells. 
    PCs = pval>0.95; 
    
    eigCent(A,PCs,bootstrap);
        figure(111); 
            legend({'Place Cells','Non-Place Cells'},'Location','Southeast'); 
        figure(222); 
            legend({'Place Cells','Non-Place Cells'},'Location','Northeast'); 
end