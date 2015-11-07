function [r,p] = corrPhysMetricCentrality(sessionStruct,centralitytype,celltype)
%
%
%

%%
    cent = parseCentrality(sessionStruct,centralitytype); 
    centStr = [upper(centralitytype(1)),centralitytype(2:end)];
    
    ind = getChampionInds(sessionStruct,celltype); 
    
    switch celltype
        case 'sigspatialinfo'
            load(fullfile(sessionStruct.Location,'SpatialInfo.mat'),'I'); 
    end
    
    [r,p] = corr(cent(ind),I(ind),'type','spearman'); 
    disp(['Rho = ',num2str(r),', p-value = ',num2str(p)]); 
    
    scatter(cent(ind),I(ind),10); 
        lsline; 
        xlabel([centStr, ' Centrality Score']); ylabel('Spatial Information [bits/s]'); 
end