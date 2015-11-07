function cent = parseCentrality(sessionStruct,centralitytype)
%
%
%

%% 
    path = sessionStruct.Location;
    switch centralitytype
            case 'eigenvector'
                load(fullfile(path,'Centralities.mat'),'eCent'); 
                cent = -eCent; 
            case 'betweenness'
                load(fullfile(path,'Centralities.mat'),'betCent'); 
                cent = betCent; 
    end
    
end