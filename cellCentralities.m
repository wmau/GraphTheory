function cellCentralities(sessionStruct,centralitytype,ind,celltype)
%cellCentralities(sessionStruct,centralitytype,ind,celltype)
%
%   Produces three figures: CDF and histogram of centrality scores for
%   champion cells and non-champion cells. Champion cells are defined by
%   cell type. Also samples centrality scores from neurons in the giant
%   component 10,000 times and averages them to produce a histogram. Then
%   plops a line indicating the mean of the empirical champion neuron
%   centrality score man. 
%
%   INPUTS
%       sessionStruct: MD entry. 
%
%       centralitytype: 'eigenvector,' 'betweenness,' or 'degree'.
%
%       ind: Index of the neurons of interest. Use getChampionInds.m. 
%
%       celltype: 'splitter,' 'sigspatialinfo,' 'nonsigspatialinfo,' or
%       'place.' Only used for legends. 
%


%% Setup.
    cent = parseCentrality(sessionStruct,centralitytype); 
    load(fullfile(sessionStruct.Location,'Graph.mat'),'gc_nodes','centroids'); 
    
    %Useful variables. 
    nInd = sum(ind);            %Number of neurons of interest.
    pool = length(ind);         %Pool from which you're sampling. 
    centStr = [upper(centralitytype(1)),centralitytype(2:end)];
    cellStr = [upper(celltype(1)),celltype(2:end)];
    B = 10000;                  %Shuffle iterations. 
    area = 100/max(cent); 
    
    %Betweenness centrality contains zeros. Make them tiny for the
    %scatterplot, but nonzero. 
    if strcmpi(centralitytype,'betweenness')
        zerocent = cent==0;
        cent(zerocent) = 0.001; 
    end

%% Highlight the champion neurons
    centroids = centroids(gc_nodes,:); 
    figure('position',[520,100,740,700]);
    subplot(2,2,1);
        hold on;
    scatter(centroids(~ind,1),centroids(~ind,2),area*cent(~ind),'g','filled');
    scatter(centroids(ind,1),centroids(ind,2),area*cent(ind),'g','filled',...
        'markeredgecolor','r'); 
        hold off; 
        axis tight;
        set(gca,'visible','off'); 
        
    %Turn 0 betweeness centralities back to zero. 
    if strcmpi(centralitytype,'betweenness')
        cent(zerocent) = 0; 
    end
    
%% CDF. 
    subplot(2,2,2);
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
        
    [~,p,D] = kstest2(cent(ind),cent(~ind));
    disp(['KS Test p=',num2str(p)]);
    disp(['D = ',num2str(D)]);
        
%% Histogram.
    [~,edges] = histcounts(cent(ind),15); 
    chmpCount = histc(cent(ind),edges)/nInd; 
    nonChmpCount = histc(cent(~ind),edges)/sum(~ind); 
    subplot(2,2,3);
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
        randNeurons = randsample(pool,nInd); 
        null(i) = mean(cent(randNeurons)); 
    end

    %Mean of PC ECs. 
    emp = mean(cent(ind)); 
    disp(['P-value: ', num2str(sum(emp<null)/B)]); 

    %Histogram of null and empirical value. 
    subplot(2,2,4);
    histogram(null,30,'normalization','probability','facecolor','k'); 
        hold on;
    lims = get(gca,'ylim'); 
    line([emp,emp],[0,lims(2)],'color','r','linewidth',2);
        title(['Bootstrapped ',centStr,' Centralities']);
        xlabel('Mean centrality score'); ylabel('Proportion'); 
        set(gca,'TickDir','out');
        
end