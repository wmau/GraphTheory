function PlotConnections(md,A)
%
%
%

%%
    cd(md.Location);
    
    [trigger,target] = find(A); 
    nEdges = length(trigger); 
    
    centroids = getNeuronCentroids(md);
    centroids(:,3) = zeros(size(centroids,1),1);
    
    PlotNeurons(md,union(trigger,target)','r',1);
    for e=1:nEdges
        mArrow3(centroids(trigger(e),:),centroids(target(e),:),'stemWidth',0.5,...
            'tipWidth',3);
    end
    
end