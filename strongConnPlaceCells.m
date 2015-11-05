function strongConnPlaceCells(A,sessionStruct)
%
%
%

%% 
    path = sessionStruct.Location; 
    
    load(fullfile(path,'PlaceMaps.mat'),'pval'); 
    
    %Get place cell indices. 
    PCs = pval>0.95; 
    
    strongConn(A,PCs);
    figure(1);
        title('Strongly Connected Component Membership'); 
        ylabel('Proportion in Giant Component'); 
        set(gca,'XTickLabel',{'Place Cells','Non-Place Cells'}); 
        set(gca,'TickDir','out');
        
    figure(2); 
        title('Network Segmentation'); 
        ylabel('Number of Components'); 
        set(gca,'XTickLabel',{'Place Cells','Non-Place Cells'}); 
        set(gca,'TickDir','out');
end