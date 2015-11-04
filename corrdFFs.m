function [r,p,dFF,raw] = corrdFFs(sessionStruct)
%[r,p,dFF,rawdF] = corrdFFs(sessionStruct)
%
%   Performs pairwise correlations between neurons based on dF/F values
%   where TENASPIS detected a spike. 
%
%   INPUT
%       sessionStruct: MD entry. 
%
%   OUTPUTS
%       r: Correlation coefficient.
%
%       p: p-value. 
%
%       dFF: dF/F of all traces (filtered by FT). 
%   
%       rawdF: dF/F of all traces (not filtered by FT). 
%

%% Align the imaging movie to the tracking. 
    %Load the variables.
    cd(sessionStruct.Location); 
    load('Dumbtraces.mat','Rawtrace'); 
    load('Pos_align.mat','FT'); 
    
    %Align trace. 
    Pix2CM = 0.15; 
    [~,~,~,Rawtrace] = AlignImagingToTracking_WM2(Pix2CM,Rawtrace);

%% Calculate dF/F and perform correlation. 
    %Get the mean fluorescence and divide fluorescence by this mean. 
    [dFF,raw] = filtdFs(Rawtrace,FT); 
    
    %Do the correlation.
    [r,p] = corr(dFF','type','Spearman'); 
    
end