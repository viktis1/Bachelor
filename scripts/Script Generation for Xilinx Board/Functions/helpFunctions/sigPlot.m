function [hPlot] = sigPlot(x,varargin)
    if nargin>1 && strcmp(varargin{1},'abs') 
        plot(abs(x),'k.-');
    elseif nargin>1 && strcmp(varargin{1},'real') 
        plot(real(x),'k.-');
    elseif nargin>1 && strcmp(varargin{1},'imag') 
        plot(imag(x),'k.-');
        
    elseif nargin>1 && strcmp(varargin{1},'scatter') 
        
        scaleVal = max(abs(x));
        scatter(real(x), imag(x), 30,'b','filled');    
        hold on;
        plot([0,0], [-scaleVal, +scaleVal], 'k--');
        plot([-scaleVal, +scaleVal], [0,0], 'k--');
        hold off;
        
        
        axis(scaleVal.*[-1,1,-1,1]);
        axis equal
       
        
    else
        hPlot(1) = plot(real(x),'b.-');
        hold on
        hPlot(2) = plot(imag(x),'r.-');
        hold off
    end
end