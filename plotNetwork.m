function plotNetwork(A,R,centroids)
%
%
%

%%
    el = adj2edgeL(A); 
    nEdges = numedges(A); 
    nNeurons = length(A);
    good = ismember(1:nNeurons,el); 
    d = degrees(A); 
    area = 0.5; 
    width = 0.1; 
    
    h = figure; 
    set(h,'Units','Inches'); 
    pos = get(h,'Position'); 
    set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);

    hold on;
    for thisEdge=1:nEdges
        cellone = el(thisEdge,1); 
        celltwo = el(thisEdge,2); 
        
        if R(cellone,celltwo)>0
            edgeColor = 'g';
        elseif R(cellone,celltwo)<0
            edgeColor = 'r';
        end
        
        patchline([centroids(cellone,1),centroids(celltwo,1)],...
            [centroids(cellone,2),centroids(celltwo,2)],...
            'Linestyle','-','Linewidth',width*abs(R(cellone,celltwo)),...
            'edgecolor',edgeColor,'Edgealpha',0.05);
    end
   
    scatter(centroids(good,1),centroids(good,2),area*d(good),'filled'); 
    hold off; 
    
    axis tight; 
    set(gca, 'visible', 'off');
    
end