

function [imSegColor] = ColorSegments(segments, colorsTable)

k = size(colorsTable, 1);
[nRows, nCols] = size(segments);
imSegColor = zeros(nRows, nCols, 3);
for iSegment = 1:k
    for iRGB = 1:3
        logicMat = false(nRows, nCols, 3);
        logicMat(:, :, iRGB) = (segments == iSegment);
        imSegColor(logicMat) = colorsTable(iSegment, iRGB);
    end
end

end
