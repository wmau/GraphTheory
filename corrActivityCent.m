function [rho,pval] = corrActivityCent(sessionStruct)
%
%
%

%%
    path = sessionStruct.Location; 
    
    load(fullfile(path,'GraphRigor.mat'),'Aprime','FT');
    
    FR = mean(FT,2); 
    eCent = eigencentrality(Aprime); 
    betCent = node_betweenness_faster(Aprime);
    rho = nan(1,2);
    pval = nan(1,2);
    
    [rho(1),pval(1)] = corr(FR,eCent,'type','spearman'); 
    [rho(2),pval(2)] = corr(FR,betCent,'type','spearman'); 
    
    disp(['Eigen rho: ',num2str(rho(1)),' p=',num2str(pval(1))]);
    disp(['Betweenness rho: ',num2str(rho(2)),' p=',num2str(pval(2))]);
    
    figure;
    scatter(FR,eCent,10);
        xlabel('Calcium Event Rate'); ylabel('Eigenvector Centrality'); 
    figure;
    scatter(FR,betCent,10);
        xlabel('Calcium Event Rate'); ylabel('Betweenness Centrality'); 
    
end