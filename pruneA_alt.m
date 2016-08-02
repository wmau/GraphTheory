function graphData_p = pruneA_alt(md)
%
%
%

%% 
    cd(md.Location); 
    load('GraphAlt.mat','A'); 
    
    nNeurons = size(A{1},1); 
    lrString = {'left','right'}; 
    
    for alt=1:2
        graphData_p(alt).A = nan(nNeurons); 
        graphData_p(alt).p = nan(nNeurons); 
        
        disp(['Analyzing ',lrString{alt}, ' trials...']); 
        p = ProgressBar(nNeurons);
        for n=1:nNeurons
            el = find(A{alt}(:,n))';
            
            if isempty(el)
                [pvals,el] = testSpreadRatio(md,graphData_p(alt),n);
                
                [~,pcrit] = fdr_bh(pvals,0.05); 
                
                graphData_p(alt).A(el(pvals<pcrit),n) = 1;
                graphData_p(alt).A(el(pvals>pcrit),n) = 0; 
                
                graphData_p(alt).p(el,n) = pvals';
            end
            
            p.progress;
        end
        p.stop;
    end
    
    keyboard;
end