function [r,p] = corrPhysMetricCentrality(sessionStruct,centralitytype,celltype)
%[r,p] = corrPhysMetricCentrality(sessionStruct,centralitytype,celltype)
%
%   This is a generalized function that allows you to correlate arbitrary
%   neurophysiological metrics (e.g., spatial information, splitting index)
%   to a centrality score. 
%
%   INPUTS
%       sessionStruct: MD entry.
%  
%       centralitytype: 'eigenvector' or 'betweenness'. 
%
%       celltype: 'sigspatialinfo' or 'nonsigspatialinfo'. 
%
%   OUTPUTS
%       r: Correlation coefficient.
%   
%       p: p-valule.
%

%% Parse inputs. 
    %Get the correct centrality score. 
    cent = parseCentrality(sessionStruct,centralitytype); 
    centStr = [upper(centralitytype(1)),centralitytype(2:end)]; %String specifying centrality.
    
    %Get indices of the cell of interest. 
    ind = getChampionInds(sessionStruct,celltype); 
    
    switch celltype
        case {'sigspatialinfo','nonsigspatialinfo'}
            load(fullfile(sessionStruct.Location,'SpatialInfo.mat'),'I'); 
    end
    
%% Perform correlation. 
    [r,p] = corr(cent(ind),I(ind),'type','spearman'); 
    disp(['Rho = ',num2str(r),', p-value = ',num2str(p)]); 

    %Scatterplot. 
    scatter(cent(ind),I(ind),10); 
        lsline; 
        xlabel([centStr, ' Centrality Score']); ylabel('Spatial Information [bits/s]'); 
        set(gca,'tickdir','out'); 
end