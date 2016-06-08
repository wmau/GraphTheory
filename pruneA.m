function graphData_p = pruneA(md,graphData)
%
%
%

%% 
    nNeurons = size(graphData.A,1);
    p = ProgressBar(nNeurons);
    
    for n=1:nNeurons
        [pval,el] = testSpreadRatio(md,graphData,n);
        
        graphData.A(el(pval<0.05),n) = 1; 
        graphData.A(el(pval>0.05),n) = 0; 
        
        p.progress;
    end
    
    graphData_p = graphData;
end