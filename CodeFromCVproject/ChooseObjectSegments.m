function [ mAlpha ] = ChooseObjectSegments(imData, segments, k)
% Select the object's segments by graphical interface

[nRows, nCols, ~] = size(imData);

% Show Segments:
colorsTable = lines(k);
imSegColor = ColorSegments(segments, colorsTable);

figure;
%  subplot(1,2,1);
% imshow(imData, 'InitialMagnification','fit'); title('Original Image');
%  subplot(1,2,2);
imshow(imSegColor, [], 'InitialMagnification','fit'); 
title({'Segments'});



figure;
% hSub1 = subplot(1,2,1);
% imshow(imData, 'InitialMagnification','fit'); title('Original Image');
% hSub2 = subplot(1,2,2);
imshow(imSegColor, [], 'InitialMagnification','fit'); 
title({'Choose Segments of the Object'});

mAlpha = false(nRows, nCols);
gotInvalidInput = false;
nSegToSelect = 1;
while (nSegToSelect > 0) && (~gotInvalidInput)
    set(gca,'Units','pixels');
    ginput(1);
    pointCoord= get(gca,'CurrentPoint');
    colPoint= round(pointCoord(1, 1));
    rowPoint = round(pointCoord(1, 2));
    gotInvalidInput = (rowPoint > nRows) ||  (rowPoint < 1) || (colPoint > nCols) ||  (colPoint < 1) ;    
        
    if ~gotInvalidInput
        nSegToSelect = nSegToSelect - 1;
        curObjSeg = segments(rowPoint, colPoint);          
        mAlpha(segments == curObjSeg) = true;
        % Mark Segment White:
        colorsTable(curObjSeg, :) = [255 255 255];
        imSegColor = ColorSegments(segments, colorsTable);

    end
end


figure;
imshow(imSegColor,  [], 'InitialMagnification','fit');
title({'Chosen Object Segment '});

end
