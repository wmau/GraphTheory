function eigCent(A,ind,bootstrap)
%
%
%

%% 
    %Get eigenvector centrality of each neuron. 
    eCent = eigencentrality(A); 
    
    %Get useful variables. 
    nind = sum(ind); 
    nNeurons = length(ind); 
    
    %Plot CDF of eigenvector centralities.
    figure(111); 
    ecdf(eCent(ind)); 
        hold on;
    ecdf(eCent(~ind)); 
        hold off;
        title('Eigenvector Centralities'); 
        xlabel('Centrality score'); ylabel('Proportion'); 
        set(gca,'TickDir','out');
        lines = get(gca,'children'); 
        set(lines(1),'color','k','linewidth',2); 
        set(lines(2),'color',[0.7 0.7 0.7],'linewidth',2); 
        
    %Histogram.
    [~,edges] = histcounts(eCent(ind),15); 
    PCcount = histc(eCent(ind),edges)/nind; 
    nonPCcount = histc(eCent(~ind),edges)/sum(~ind); 
    figure(222);
        hold on;
    stairs(edges,PCcount,'linewidth',2,'color','k');     
    stairs(edges,nonPCcount,'linewidth',2,'color',[0.7,0.7,0.7]); 
        lims = get(gca,'ylim'); 
    line([median(eCent(ind)),median(eCent(ind))],[0,lims(2)],'linestyle','--','color','k');
    line([median(eCent(~ind)),median(eCent(~ind))],[0,lims(2)],'linestyle','--','color',[0.7 0.7 0.7]);
        hold off; 
        title('Eigenvector Centralities'); 
        xlabel('Centrality score'); ylabel('Proportion'); 
        set(gca,'TickDir','out');
             
    %Take a look at the mean EC. Randomly sample from N (number of place
    %cells) neurons and look at their centrality. Take the mean of this
    %population and compare to the place cell centralities. 
    if bootstrap
        B = 10000; 
        
        %Prealloacte. 
        null = nan(1,B); 
        
        %Randomly sample from non-place cell ECs. 
        for i=1:B
            randNeurons = randsample(nNeurons,nind); 
            null(i) = mean(eCent(randNeurons)); 
        end
        
        %Mean of PC ECs. 
        emp = mean(eCent(ind)); 
        disp(['P-value: ', num2str(sum(emp<null)/B)]); 

        %Histogram of null and empirical value. 
        figure(333);
        histogram(null,30,'normalization','probability','facecolor','k'); 
            hold on;
        lims = get(gca,'ylim'); 
        line([emp,emp],[0,lims(2)],'color','r','linewidth',2);
            title('Bootstrapped Eigenvector Centralities');
            xlabel('Mean centrality score'); ylabel('Proportion'); 
            set(gca,'TickDir','out');
    end
    
end