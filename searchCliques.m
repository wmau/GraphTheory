function [cliques,randCliques] = searchCliques(A,ind)
%[cliques,randCliques] = searchCliques(A,ind)
%
%

%% 
    %Get cliques. 
    MC = ELSclique(A); 
    MC = full(MC); 
    
    %Useful parameters and preallocate. 
    nCliques = size(MC,2);              %Number of cliques. 
    cliques = nan(nCliques,1); 
    B = 1000;
    randCliques = nan(nCliques,B); 
    cellnum = find(ind); 
    
    %Compute the proportion of the clique that is a champion cell. 
    for thisClique=1:nCliques
        cliqueNeurons = find(MC(:,thisClique)); 
        if any(ismember(cellnum,cliqueNeurons))
            %Proportion of the clique that is a champion cell. 
            cliques(thisClique,1) = propChampinClique(cellnum,cliqueNeurons);
            cliques(thisClique,2) = length(cliqueNeurons);   %Length of the clique. 
        else
            cliques(thisClique,1) = nan; 
        end
    end

%% Bootstrap by taking random neuron indices. 
    p = ProgressBar(B); 
    for i=1:B
        randidx = randsample(length(ind),sum(ind)); 
        
        for thisClique=1:nCliques
            cliqueNeurons = find(MC(:,thisClique)); 
            if any(ismember(randidx,cliqueNeurons))
                randCliques(thisClique,i) = propChampinClique(randidx,cliqueNeurons);
            else
                randCliques(thisClique,i) = nan; 
            end

        end
        p.progress; 
    end
    p.stop; 
    
    meanCliqueProp = nanmean(cliques(:,1)); 
    randmeans = nanmean(randCliques); 
    
    figure;
    histogram(randmeans,'facecolor','k'); 
    lims = get(gca,'ylim'); 
    line([meanCliqueProp,meanCliqueProp],lims,'color','r','linewidth',2);
        xlabel('Clique Co-membership'); ylabel('Count'); 
        set(gca,'tickdir','out'); 
    
end

function prop = propChampinClique(cellnum,cliqueNeurons)
    prop = sum(ismember(cellnum,cliqueNeurons))/length(cliqueNeurons);
end