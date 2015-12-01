function cent = parseCentrality(sessionStruct,centralitytype)
%cent = parseCentrality(sessionStruct,centralitytype)
%
%   Extracts pre-computed centrality scores from saved mat files. Specify
%   the type of centrality you want.
%
%   INPUTS
%       sessionStruct: MD entry. 
%
%       centralitytype: 'eigenvector,' 'betweenness,' or 'degree.'
%

%% 
    path = sessionStruct.Location;
    switch centralitytype
        case 'eigenvector'
            load(fullfile(path,'Centralities.mat'),'eCent'); 
            cent = eCent; 
        case 'betweenness'
            load(fullfile(path,'Centralities.mat'),'betCent'); 
            cent = betCent; 
        case 'degree'
            load(fullfile(path,'Centralities.mat'),'d');
            cent = d; 
    end
    
end