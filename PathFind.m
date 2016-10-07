function ListofPathLists = PathFind(sink,PathList,ListofPathLists,el)
%ListofPathLists = PathFind(sink,PathList,ListofPathLists,el)
%
%   Pseudocode used from here: 
%   <http://stackoverflow.com/questions/58306/graph-algorithm-to-find-all-connections-between-two-arbitrary-vertices>
%
%   Compiles a list of paths leading to a destination (sink) node. 
%
%   INPUTS
%       sink: A target neuron. 
%
%       PathList: An existing vector of neuron indices starting at the
%       first entry which should connect to subsequent entries. 
%
%       ListofPathLists: Cell array of PathLists. 
%
%       el: Edge list. From adj2edgeL.m.
%
%   OUTPUT
%       ListofPathLists: Cell array of PathLists.
%
%   TO USE: Usually, PathFind(target,[],cell(1),el);
%

%% Get path list.
    %First iteration of PathFind will have the target neuron in the
    %variable sink. Append it to the front of the list. Further iterations
    %of PathFind will append the trigger neuron. 
    PathList = [sink PathList];
    
    %Prevents creating infinite lists if there is a reciprocal connection.
    %If there are multiple copies of one number, delete the first entry,
    %which should have been the copy. Append PathList to the
    %ListofPathLists then exit. 
    if length(unique(PathList)) < length(PathList)
        PathList(1) = [];
        ListofPathLists{end+1} = PathList;
        return;
    end
    
    %Continuing on...if the above condition wasn't met, look for neurons
    %that connect to 'sink'. 
    sources = el(el(:,2)==sink,1)';
    
    %If there are no more, exit. 
    if isempty(sources)
        ListofPathLists{end+1} = PathList;
    end
    
    %Otherwise, run this function again with the source neuron as the sink.
    for s=sources
        ListofPathLists = PathFind(s,PathList,ListofPathLists,el);
    end
end