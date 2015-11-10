function corrCentralitySpatialInfo(sessionStruct,centralitytype)
%
%
%

%% 
    path = sessionStruct.Location; 
    
    cent = parseCentrality(sessionStruct,centralitytype);
    
    [r_sig,p_sig] = corr(cent(sig),I(sig),'type','spearman'); 
    [r_nonsig,p_nonsig] = corr(cent(nonsig),I(nonsig),'type','spearman'); 
    [r_all,p_all] = corr(cent,I,'type','spearman'); 
    
    figure;
    hold on;
    %scatter(eCent(nonsig),I(nonsig),10,'g'); 
    scatter(cent(sig),I(sig),10,'b');
        lsline;
        %set(l(1),'color','b'); set(l(2),'color','g'); 
        title('Centrality and Spatial Information Correlation'); 
        xlabel([centstr, ' Centrality']); 
        ylabel('Spatial Information [bits/s]'); 
        set(gca,'tickdir','out');
        %legend({'Nonspatial Cells','Spatial Cells'});
        
    disp(['Rho between significant spatial information neurons: ',num2str(r_sig),', p=',num2str(p_sig)]);
    disp(['Rho between nonsignificant spatial information neurons: ',num2str(r_nonsig),', p=',num2str(p_nonsig)]);
    disp(['Rho between all neurons: ',num2str(r_all),', p=',num2str(p_all)]);

    
end