function [eCent,PCs] = eigPlaceCells(A,sessionStruct,bootstrap)
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
    
    eCent = eigCent(A,PCs,bootstrap);

end