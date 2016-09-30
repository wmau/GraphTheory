function PlotPath(md,path,colors)
%
%
%

%%
    cd(md.Location);
    
    centroids = getNeuronCentroids(md);
    centroids(:,3) = zeros(size(centroids,1),1);
    nNeurons = size(centroids,1);
    pl = length(path);
    
    PlotNeurons(md,1:nNeurons,'k',.1);
    for e=1:pl-1
        mArrow3(centroids(path(e),:),centroids(path(e+1),:),'stemWidth',.5,...
            'tipWidth',3);
    end
    
    for e=1:pl
        PlotNeurons(md,path(e),colors(e,:),3);
    end
end