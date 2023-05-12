function [text] = titlePrint(text,varargin)
%TITLEPRINT 

vecSearch = '_.()';

if iscell(text) % For cell-array of strings
    Nrun = numel(text);
    Ctext = text; clear text;    
    for jj=1:Nrun
        text = Ctext{jj};
        if nargin > 1 % Possible removal of string corresponding to second optional argument
            rmvSearch = varargin{1};
            if iscell(rmvSearch)
                for j2=1:numel(rmvSearch)
                    idx = strfind(text,rmvSearch{j2}); text(idx:(idx+numel(rmvSearch)-1)) = [];
                end
            else
                idx = strfind(text,rmvSearch); text(idx:(idx+numel(rmvSearch)-1)) = [];
            end
        end
        
        if nargin~=3 % Allow for cleanup proces to be skipped with 3rd input (solely use the above search N remove functionality)
            for ii=1:numel(vecSearch)
                if strcmp(vecSearch(ii),'(') || strcmp(vecSearch(ii),')')
                    repChar = '-';
                else
                    repChar = ' ';
                end
                text(strfind(text,vecSearch(ii))) = repChar;


                Ctext{jj} = text;
            end
        else
            Ctext{jj} = text;
        end
    end
    clear text;
    text = Ctext;
else % Single string
    if nargin > 1 % Possible removal of string corresponding to second optional argument
        rmvSearch = varargin{1};
        if iscell(rmvSearch)
            for j2=1:numel(rmvSearch)
                idx = strfind(text,rmvSearch{j2}); text(idx:(idx+numel(rmvSearch)-1)) = [];
            end
        else
            idx = strfind(text,rmvSearch); text(idx:(idx+numel(rmvSearch)-1)) = [];
        end
    end
    if nargin~=3 % Allow for cleanup proces to be skipped with 3rd input
        for ii=1:numel(vecSearch)
            if strcmp(vecSearch(ii),'(') || strcmp(vecSearch(ii),')')
                repChar = '-';
            else
                repChar = ' ';
            end

            text(strfind(text,vecSearch(ii))) = repChar;
        end
    end
end

end

