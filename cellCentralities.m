function cellCentralities(sessionStruct,centralitytype,ind,celltype)
%
%
%

%% Setup.
    cent = parseCentrality(sessionStruct,centralitytype); 

    
    %Useful variables. 
    nInd = sum(ind);            %Number of neurons of interest.
    nNeurons = length(ind);     %Total number of neurons. 
    centStr = [upper(centralitytype(1)),centralitytype(2:end)];
    cellStr = [upper(celltype(1)),celltype(2:end)];
    B = 10000; 
    
%% CDF. 
    figure;
    ecdf(cent(ind)); 
        hold on;
    ecdf(cent(~ind)); 
        hold off; 
        title([centStr,' Centralities']); 
        xlabel('Centrality Score'); ylabel('Proportion'); 
        set(gca,'TickDir','out');
        lines = get(gca,'children'); 
        set(lines(2),'color','k','linewidth',2); 
        set(lines(1),'color',[0.7 0.7 0.7],'linewidth',2); 
        legend({[cellStr,' Cells'],['Non-',cellStr,' Cells']},'location','southeast');
        
%% Histogram.
    [~,edges] = histcounts(cent(ind),15); 
    chmpCount = histc(cent(ind),edges)/nInd; 
    nonChmpCount = histc(cent(~ind),edges)/sum(~ind); 
    figure;
        hold on;
    stairs(edges,chmpCount,'linewidth',2,'color','k');     
    stairs(edges,nonChmpCount,'linewidth',2,'color',[0.7,0.7,0.7]); 
        lims = get(gca,'ylim'); 
    line([median(cent(ind)),median(cent(ind))],[0,lims(2)],'linestyle','--','color','k');
    line([median(cent(~ind)),median(cent(~ind))],[0,lims(2)],'linestyle','--','color',[0.7 0.7 0.7]);
        hold off; 
        title([centStr,' Centralities']); 
        xlabel('Centrality score'); ylabel('Proportion'); 
        legend({[cellStr,' Cells'],['Non-',cellStr,' Cells']});
        set(gca,'TickDir','out');    
        
%% Bootstrap. 
    %Preallocate. 
    null = nan(1,B); 

    %Randomly sample from non-place cell ECs. 
    for i=1:B
        randNeurons = randsample(nNeurons,nInd); 
        null(i) = mean(cent(randNeurons)); 
    end

    %Mean of PC ECs. 
    emp = mean(cent(ind)); 
    disp(['P-value: ', num2str(sum(emp<null)/B)]); 

    %Histogram of null and empirical value. 
    figure;
    histogram(null,30,'normalization','probability','facecolor','k'); 
        hold on;
    lims = get(gca,'ylim'); 
    line([emp,emp],[0,lims(2)],'color','r','linewidth',2);
        title(['Bootstrapped ',centStr,' Centralities']);
        xlabel('Mean centrality score'); ylabel('Proportion'); 
        set(gca,'TickDir','out');
        
end