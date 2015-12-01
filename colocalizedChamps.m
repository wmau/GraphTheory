function [cliques,randCliques] = colocalizedChamps(sessionStruct,celltype)
%
%
%

%%
    path = sessionStruct.Location;
    load(fullfile(path,'Graph.mat'),'GC');
    ind = getChampionInds(sessionStruct,celltype);
    
    [cliques,randCliques] = searchCliques(GC,ind);
    
end
