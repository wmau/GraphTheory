function [A,R,d,p,centroids,dFF] = MakeGraph(sessionStruct,downsample,plot,mcmode)
%[A,R,d,p,centroids,dFF] = MakeGraph(folder,downsample,plot,mcmode)
%
%   Make a graph with neurons as nodes where edges are defined by the top
%   1% of statistically significant correlation coefficients. 
%
%   INPUTS
%       folder: Directory containing ProcOut.
%
%       downsample: 0 or 1 describing whether or not you want to set a
%       percentile threshold for correlation coefficients to define an
%       edge.
%
%       plot: 0 or 1 describing whether or not you want to plot the graph.
%
%       mcmode: 'Bonferroni' or 'FDR'. 
%
%   OUTPUTS
%       A: Adjacency matrix. 
%
%       R: Weighted adjacency matrix. 
%
%       d: Degrees per node. 
%
%       
%

%% Initialize. 
    %Load the appropriate variables. 
    folder = sessionStruct.Location; 
    load(fullfile(folder,'ProcOut.mat'),'FT','NeuronImage'); 
    NumNeurons = size(FT,1); 
    neuronid = 1:NumNeurons;
    thresh = 99;        %Percentile of significant correlation coefficients. 
    width = 0.1;        %Constant multiplying correlation coefficient to determine edge thickness. 
    areafactor = 0.5;   %Constant multiplying vertex area. 

%% Do pairwise correlations and set thresholds. 
    %Perform pairwise correlations between neurons. 
    [R,p,dFF] = corrdFFs(sessionStruct);  
    A = R;
    
    %Get significance level. 
    switch lower(mcmode)
        case 'fdr'
            pforfdr = triu(p); 
            pforfdr(pforfdr==0 & p~=0) = nan;       %Remove bottom triangle of matrix. 
            pforfdr = pforfdr(:);
            pforfdr(isnan(pforfdr)) = []; 
            [~,crit,~] = fdr_bh(pforfdr);           %Get false discovery rate threshold.
        case 'bonferroni'
            n = (NumNeurons-1)*NumNeurons/2; 
            crit = 0.05/n;
    end
            
%% Create A. 
    %Shape the correlation coefficient matrix. 
    sparseR = triu(R);                  %Upper triangle of matrix. 
    sparseR(sparseR==0 & R~=0) = nan;   %Turn zeros into NaNs. 
    sparseR(p>crit) = nan;              %Remove insignificant correlations. Includes diag.
    R(p>crit) = 0; 
    
    if downsample
        lim = prctile(sparseR(:),thresh);   %Define threshold. 
        sparseR(sparseR<lim) = nan;         %Threshold.  
        R(R<lim) = nan;
    end

    %Find neurons that connect to other neurons. 
    [r,c] = find(~isnan(sparseR)); 
    badneurons = ~ismember(neuronid,r) & ~ismember(neuronid,c);
    goodneurons = ~badneurons;
    
    %Get degree list.      
    if downsample
        A(A<lim) = 0; 
        A(A>lim) = 1; 
    else
        A(p>crit) = 0;
        A(p<crit) = 1; 
    end
    A(isnan(A)) = 0; 
    d = sum(A,2); 
    
%% Get neuron centroids. 
    props = cellfun(@regionprops,NeuronImage); 
    temp = extractfield(props,'Centroid'); 
    centroids = [temp(1:2:end)', temp(2:2:end)']; 
    
%% Plot.
    if plot
        h = figure;
        set(h,'Units','Inches'); 
        pos = get(h,'Position'); 
        set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)]);

        %For showing projection. 
        %minproj = imread(fullfile(folder,'ICmovie_min_proj.tif')); 
        %imshow(minproj,[]);
        hold on;

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
            patchline([centroids(cellone,1),centroids(celltwo,1)],...
                [centroids(cellone,2),centroids(celltwo,2)],...
                'Linewidth',width*abs(sparseR(cellone,celltwo)),...
                'edgecolor',edgecolor,'Edgealpha',0.2);
        end

    
    %Overlay nodes. 
    scatter(centroids(goodneurons,1),centroids(goodneurons,2),...
        areafactor*d(goodneurons),'filled'); 
    hold off; 
    
    axis tight; 
    set(gca, 'visible', 'off');
    %print(h,'Graph','-dpdf','-r0');
    
    end
    
    R(isnan(R)) = 0; 
    
    %save('Graph.mat','A','R','d','p','centroids','dFF'); 
   
end
    