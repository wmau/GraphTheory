function ListofPathLists = PathFind(sink,PathList,ListofPathLists,el)
%ListofPathLists = PathFind(sink,PathList,ListofPathLists,el)
%
%   Pseudocode used from here: 
%   <http://stackoverflow.com/questions/58306/graph-algorithm-to-find-all-connections-between-two-arbitrary-vertices>
%
%   Compiles a list of paths leading to a destination (sink) node. 

%%
    PathList = [sink PathList];
    if length(unique(PathList)) < length(PathList)
        PathList(1) = [];
        ListofPathLists{end+1} = PathList;
        return;
    end
    
    sources = el(el(:,2)==sink,1)';
    
    if isempty(sources)
        ListofPathLists{end+1} = PathList;
    end
    
    for s=sources
        ListofPathLists = PathFind(s,PathList,ListofPathLists,el);
    end
end