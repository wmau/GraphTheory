function ind = getChampionInds(sessionStruct,celltype)
%ind = getChampionInds(sessoinStruct,celltype)
%
%   Extracts the indices of the giant component of the network graph that
%   reference neurons of interest. 
%
%   INPUTS
%       sessionStruct: MD entry. 
%
%      celltype: 'splitter,' 'sigspatialinfo,' 'nonsigspatialinfo,' or
%       'place.'
%
%   OUTPUT
%       ind: Nx1 vector (N=number of nodes in giant component) ndexing the
%       giant component of the network graph that correspond to the type of
%       neuron specified.
%


%% Parse the cell type. 
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
    