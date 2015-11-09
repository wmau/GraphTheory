function cellTypeCentralities(sessionStruct,centralitytype,celltype)
%cellTypeCentralitise(sessionStruct,centralitytype,celltype)
%
%   Top level function for looking at centrality score distributions of
%   various cell types. 
%
%   INPUTS
%       sessionStruct: MD entry.
%
%       centralitytype: 'eigenvector,' 'betweenness,' or 'degree.'
%
%       celltype: 'splitter,' 'sigspatialinfo,' 'nonsigspatialinfo,' or
%       'place.'
%

    ind = getChampionInds(sessionStruct,celltype); 
    
    cellCentralities(sessionStruct,centralitytype,ind,celltype); 
    
end