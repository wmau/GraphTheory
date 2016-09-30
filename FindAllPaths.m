function [AllPaths,targets] = FindAllPaths(A)
%
%
%

%%
    el = adj2edgeL(A);
    el = el(:,1:2); 
    
    targets = unique(el(:,2))'; 
    nTargets = length(targets);
    AllPaths = cell(nTargets,1);
    minLength = 3; 
    for t = 1:nTargets
        AllPaths{t} = PathFind(targets(t),[],cell(1),el);
        PathLengths = cellfun('length',AllPaths{t});
        AllPaths{t}(PathLengths < minLength) = [];
    end
        
end
    
    