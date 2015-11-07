function ind = getChampionInds(sessionStruct,celltype)
%
%
%

%% 
    path = sessionStruct.Location;
    
    load(fullfile(path,'GraphRigor.mat'),'gc_nodes'); 
    switch celltype
        case 'splitter'
            load(fullfile(path,'sigSplitters.mat'),'sigcurve');
            splitters = cellfun(@any,sigcurve); 
            ind = splitters(gc_nodes); 
            
        case 'sigspatialinfo'
            load(fullfile(path,'SpatialInfo.mat'),'sig');
            ind = sig(gc_nodes);
            
        case 'nonsigspatialinfo'
            load(fullfile(path,'SpatialInfo.mat'),'nonsig');
            ind = nonsig(gc_nodes); 
            
        case 'place'
            load(fullfile(path,'PlaceMaps.mat'),'pval'); 
            place = pval > 0.95; 
            ind = place(gc_nodes); 
    end
    
end
    