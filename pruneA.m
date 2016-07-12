function graphData_p = pruneA(md,graphData)
%graphData_p = pruneA(md,graphData)
%
%   Prune the adjacency matrix of un-sequencey neurons. 

%% 
    graphData_p = graphData;
    nNeurons = size(graphData_p.A,1);
    graphData_p.prune_p = nan(nNeurons); 
    p = ProgressBar(nNeurons);
    
    for n=1:nNeurons
        el = find(graphData.A(:,n))';
        
        if ~isempty(el)
            [pvals,el] = testSpreadRatio(md,graphData_p,n);

            [~,pcrit] = fdr_bh(pvals,0.05); 
            
            graphData_p.A(el(pvals<pcrit),n) = 1; 
            graphData_p.A(el(pvals>pcrit),n) = 0; 

            graphData_p.prune_p(el,n) = pvals'; 
        end
        
        p.progress;
    end
    
    save('Graphv4.mat','graphData','graphData_p','-v7.3');
end