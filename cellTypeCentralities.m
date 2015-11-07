function cellTypeCentralities(sessionStruct,centralitytype,celltype)
%
%
%

%% 
    ind = getChampionInds(sessionStruct,celltype); 
    
    cellCentralities(sessionStruct,centralitytype,ind); 
    
end