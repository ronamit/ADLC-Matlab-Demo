function [ nbEdges ] = GetNeighborEdges( nRows, nCols,  nieghborhoodType)

% Output:
% nbEdges [nEdges x 2] - Each row is the linear indicies (column-major) of pixels in an edge.

addReverseEdges = true; % Add the edges with flipped directions

switch (nieghborhoodType)
    case '4-nieghborhood'
        nPixels = nRows*nCols;
        % connect vertically (down, then up)
        node1 = (1:nPixels)';
        node1(nRows:nRows:nPixels)=[];
        node2 = node1 + 1;
        nbEdges1 = [node1];
        nbEdges2 = [node2];
        % connect horizontally (right, then left)
        node1 = (1:(nPixels - nRows))';
        node2 = node1 + nRows;
        nbEdges1 = [nbEdges1;node1];
        nbEdges2 = [nbEdges2;node2];
        nbEdges = [nbEdges1,nbEdges2];
        
        
    case '8-nieghborhood'
        nPixels = nRows*nCols;
        % connect vertically (down, then up)
        node1 = (1:nPixels)';
        node1(nRows:nRows:nPixels)=[];
        node2 = node1 + 1;
        nbEdges1 = [node1]; 
        nbEdges2 = [node2]; 
        % connect horizontally (right, then left)
        node1 = (1:(nPixels - nRows))';
        node2 = node1 + nRows;
        nbEdges1 = [nbEdges1;node1]; 
        nbEdges2 = [nbEdges2;node2]; 
        
        % connect first diagonal (down-right, then up-left)
        node1 = (1:(nPixels - nRows))';
        node1(nRows:nRows:end)=[];
        node2 = node1 + 1 + nRows;
        nbEdges1 = [nbEdges1;node1]; 
        nbEdges2 = [nbEdges2;node2]; 
        % connect second diagonal ( up-right , then down-left)
        node1 = (1:(nPixels - nRows))';
        node1(1:nRows:end)=[];
        node2 = node1 - 1 + nRows;
        nbEdges1 = [nbEdges1;node1]; 
        nbEdges2 = [nbEdges2;node2]; 
        
        nbEdges = [nbEdges1,nbEdges2];
end


if addReverseEdges  
    nbEdges = [nbEdges; fliplr(nbEdges)];
end
end

