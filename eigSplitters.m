function splitters = eigSplitters(A,sessionStruct,bootstrap)
%
%
%

%% 
    %Get filepath.
    path = sessionStruct.Location; 
    
    %Load splitter data. 
    load(fullfile(path,'sigSplitters.mat'),'sigcurve');
    
    %Get indices of splitters.
    splitters = cellfun(@any,sigcurve);
    
    eigCent(A,splitters,bootstrap);

end