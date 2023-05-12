function [ output_args ] = FigText(Title,Xlab,Ylab,Scale,TScale,Zlab)
% FIGTEXT:      Standardizes the usage of textlabels for figures. Takes
%               input for x-, y- and possibly z-axis (depends on number of inputs). 
%               Made with the purpose of condensing code for figures. 
%               
% HINTS:        - Write "listfonts" in the console to see available
%                 fonttypes.
%               - Future possibilities for expansion, see guide on:
%                 http://blogs.mathworks.com/loren/2007/12/11/making-pretty-graphs/

% Set backgroundcolor to plain white
% colordef 'white'

set(gcf,'color','w')
% In case of 5 numbers of input, don't use zlabel
if nargin == 5
%TITLE
set(gca,'FontSize',TScale);  
set(gca,'FontName','Helvetica');
title(Title);

%AXISTITLES
set(gca,'FontSize',Scale);     
set(gca,'FontName','AvantGarde');
xlabel(Xlab);
ylabel(Ylab);

% In case of 5 numbers of input, DO use zlabel
elseif nargin == 6
%TITLE
set(gca,'FontSize',TScale)          
set(gca,'FontName','Helvetica')
title(Title)

%AXISTITLES
set(gca,'FontSize',Scale)          
set(gca,'FontName','AvantGarde')
xlabel(Xlab);
ylabel(Ylab);
zlabel(Zlab); 
end


end

