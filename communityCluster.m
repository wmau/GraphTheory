function [VV,clusters] = communityCluster(animal,date,session,A,method)
%
%
%

%% 
    %Find out whether graph is directed or undirected. 
    undirected = issymmetric(A);

    %Community detection method. 
    switch method
        case 'newman-greedy'
            VV = GCModulMax3(A);
        case 'louvain'
            [modules,inmodule] = louvain_community_finding(A);
            VV = cell2mat(inmodule);
        case 'stabilityopt'
            VV = GCStabilityOpt(A,1);
        case 'danon'
            VV = GCDanon(A);
    end
    
    %Get some descriptive statistics about the communities. 
    tbl = tabulate(VV);
    [~,order] = sort(tbl(:,2),'descend');       %Sort the clusters. 
    top = 4;                                    %Top X largest clusters.
    clusters = tbl(order(1:top),1);             %Clusters. 
    nClusters = length(clusters);               %Number of clusters. 
    
    %Neuron centroids.
    centroids = getNeuronCentroids(animal,date,session);

    %Null distribution of centroid distances, using all the neurons. 
    null = pdist(centroids,'euclidean');
    null2 = pdist(centroids(ismember(VV,clusters),:),'euclidean');

%% 
    %Preallocate. 
    d = cell(nClusters,1);
    H = zeros(nClusters,1); p = zeros(nClusters,1);
    
    %Initialize figures.
    figure('Position',[-1660 85 1440 650]);
%     subplot(1,2,1);
%         scatter(centroids(:,1),centroids(:,2),'.');           %Neuron topography (all).
%         hold on; axis tight; axis off; 
    subplot(1,2,2); hold on;                                    %Distance CDF.
    
    %Edge list. 
    el = getEdges(A,'adj');
    nEdges = numedges(A);
    
    %Plot the edges.
    subplot(1,2,1);
    for i=1:nEdges
        cellone = el(i,1); 
        celltwo = el(i,2);
        if ~undirected
            mArrow3([centroids(cellone,:) 0],[centroids(celltwo,:) 0],...
                'facealpha',0.1,'stemWidth',0.5,'tipWidth',1.5);

        elseif undirected
            patchline([centroids(cellone,1),centroids(celltwo,1)],...
                [centroids(cellone,2),centroids(celltwo,2)],'Edgealpha',0.05);
        end
    end
    
%% Plot communities. 
    for i=1:nClusters
        thisCluster = clusters(i);
        inCluster = find(VV==thisCluster);
        
        %Color each node that lives in a community. 
        subplot(1,2,1); hold on;
        scatter(centroids(inCluster,1),centroids(inCluster,2),300,'.');
        
        %Get distance intercommunity neurons. 
        d{i} = pdist(centroids(VV==thisCluster,:),'euclidean'); 
    
        %Plot CDF of distances. 
        subplot(1,2,2);
        ecdf(d{i});
        [H(i),p(i)] = kstest2(d{i},null2);
    
        %If significant, make the line dashed. 
        if H(i)
            h = get(gca,'children');
            set(h(1),'linestyle','--');
        end
    end
    
    %Get rid of axis. 
    subplot(1,2,1); axis tight; axis off; 
    
    %Plot the null distribution.
    subplot(1,2,2);
    ecdf(null); ecdf(null2); 
    h = get(gca,'children');
    set(h(1),'linewidth',3);
    set(h(2),'linewidth',3,'linestyle',':');
    
end