function getCentralities(A)
%
%
%

%% 
    betCent = node_betweenness_faster(A);
    eCent = eigencentrality(A)'; 
    d = degrees(A); 
   
    save('Centralities.mat','betCent','eCent','d'); 
end