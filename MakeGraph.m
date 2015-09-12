function MakeGraph(folder)
%MakeGraph(folder)
%
%   Make a graph with neurons as nodes where edges are defined by the top
%   1% of statistically significant correlation coefficients. 
%
%   INPUT
%       folder: Directory containing ProcOut.
%

%% Initialize. 
    %Load the appropriate variables. 
    load(fullfile(folder,'ProcOut.mat'),'FT','NeuronImage'); 
    NumNeurons = size(FT,1); 
    neuronid = 1:NumNeurons;
    thresh = 99;    %Percentile of significant correlation coefficients. 
    width = 3;      %Constant multiplying correlation coefficient to determine edge thickness. 
    
%% 
    %Perform pairwise correlations between neurons. 
    [R,pval] = corr(FT'); 
    
    %Shape the correlation coefficient matrix. 
    sparseR = triu(R);                  %Upper triangle of matrix. 
    sparseR(sparseR==0 & R~=0) = nan;   %Turn zeros into NaNs. 
    sparseR(pval>0.05) = nan;           %Remove insignificant correlations. Includes diag. 
    lim = prctile(sparseR(:),thresh);   %Define threshold. 
    sparseR(sparseR<lim) = nan;         %Threshold.  
    
    %Find neurons that connect to other neurons. 
    [r,c] = find(~isnan(sparseR)); 
    badneurons = ~ismember(neuronid,r) & ~ismember(neuronid,c);
    goodneurons = ~badneurons;
        
%% Get neuron centroids. 
    props = cellfun(@regionprops,NeuronImage); 
    temp = extractfield(props,'Centroid'); 
    centroids = [temp(1:2:end)', temp(2:2:end)']; 
    
%% Plot.
    h = figure(2);
    set(h,'Units','Inches'); 
    pos = get(h,'Position'); 
    set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);
    
    %Plot edges.
    numedges = length(r); 
    for thisedge=1:numedges
        cellone = r(thisedge); 
        celltwo = c(thisedge); 
        
        %Color negative correlations red. Otherwise, green.
        if sparseR(cellone,celltwo) < 0
            edgecolor = 'r'; 
        elseif sparseR(cellone,celltwo) > 0 
            edgecolor = 'g'; 
        end
       
        %Draw edges. 
        line([centroids(cellone,1),centroids(celltwo,1)],...
            [centroids(cellone,2),centroids(celltwo,2)],...
            'Linewidth',width*sparseR(cellone,celltwo),...
            'Color',edgecolor);
    end
    hold on;
    
    %Overlay nodes. 
    scatter(centroids(goodneurons,1),centroids(goodneurons,2),'filled'); 
    hold off; 
    
    axis tight; 
    set(gca, 'visible', 'off') ;
    print(h,'Graph','-dpdf','-r0');
   
end
    