function graphData_p = pruneA(graphData)
%graphData_p = pruneA(md,graphData)
%
%   Prune the adjacency matrix of un-sequencey neurons. 

%% 
    graphData_p = graphData;
    nNeurons = size(graphData_p.A,1);
    graphData_p.prune_p = nan(nNeurons); 
    p = ProgressBar(nNeurons);
    
    pcrit = 0.01;
    for n=1:nNeurons
        el = find(graphData.A(:,n))';
        
        if ~isempty(el)
            [pvals,el] = trialShuffleKSTest(graphData_p,n);
%             pvals_corrected = pvals(pvals~=1); 
% 
%             if ~isempty(pvals_corrected)
%                 [~,pcrit] = fdr_bh(pvals_corrected,0.05);
%             else 
%                 pcrit = 0;
%             end
            
            graphData_p.A(el(pvals<=pcrit),n) = true; 
            graphData_p.A(el(pvals>pcrit),n) = false; 

            graphData_p.prune_p(el,n) = pvals'; 
        end
        
        p.progress;
    end
    
    save('Graphv4.mat','graphData','graphData_p','-v7.3');
end