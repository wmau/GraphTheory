function corrEigCentSpatialInfo(sessionStruct)
%
%
%

%% 
    path = sessionStruct.Location; 
    
    load(fullfile(path,'GraphRigor.mat'));
    load(fullfile(path,'SpatialInfo.mat')); 
    
    eCent = eigencentrality(Aprime); 
    
    [r_sig,p_sig] = corr(eCent(sig),I(sig)); 
    [r_nonsig,p_nonsig] = corr(eCent(nonsig),I(nonsig)); 
    [r_all,p_all] = corr(eCent,I); 
    
    figure;
    hold on;
    scatter(eCent(nonsig),I(nonsig),10,'g'); 
    scatter(eCent(sig),I(sig),10,'b');
        l = lsline;
        set(l(1),'color','b'); set(l(2),'color','g'); 
        title('Relationship between Eigenvector Centrality and Spatial Information'); 
        xlabel('Eigenvector Centrality'); 
        ylabel('Spatial Information [bits/s]'); 
        set(gca,'tickdir','out');
        legend({'Nonspatial Cells','Spatial Cells'});
        
    disp(['Rho between significant spatial information neurons: ',num2str(r_sig),', p=',num2str(p_sig)]);
    disp(['Rho between nonsignificant spatial information neurons: ',num2str(r_nonsig),', p=',num2str(p_nonsig)]);
    disp(['Rho between all neurons: ',num2str(r_all),', p=',num2str(p_all)]);

    
end