function [ mAlpha, grayScaleIm] = RunSegmentationByFeatures( imData,  mAlpha, sOpts)

% Choose the number of clusters and the clustering method.
k = sOpts.k;


% Use all of the above parameters to actually compute a segmentation.
segments = ComputeSegmentation(imData, mAlpha, sOpts);

% Morpholigical Improvment Operations:
% maxSeSize = 2; %
% for iSeg = 1:k
%     binIm = (segments == iSeg);
%     [ binIm ] = MorphologicalImprovent( binIm, maxSeSize );
%     segments(binIm) = iSeg;
% end

% Show Segments:
colorsTable = lines(k);
imSegColor = ColorSegments(segments, colorsTable);
figure;
subplot(1,2,1);
imshow(imData, 'InitialMagnification','fit'); title('Original Image');
subplot(1,2,2);
imshow(imSegColor, [], 'InitialMagnification','fit');
title({'K-Means Result'});


newSegIdx = 1;
for iSeg = 1:k
    segIm = (segments == iSeg);
    %     figure; imshow(segIm);
    sComp = bwconncomp(segIm);
    nComp = length(sComp.PixelIdxList);
    for iComp = 1:nComp
        pixIndList =  sComp.PixelIdxList{iComp};
        if(length(pixIndList) < sOpts.MinPixForObj)
            % not a valid segment to be an object (letter)
            % TODO: Adde test about location
            segMark = 0;
        else
            segMark = newSegIdx;
        end
        segments(pixIndList) = segMark;
        newSegIdx = newSegIdx + 1;
    end
end
newSegInds = ReindexClusters(segments(:));
segments = reshape(newSegInds, size(segments));

figure; histogram(segments(:)); xlabel('Segment Index'); ylabel('Pixels'); grid on;

nSegments = max(segments(:));

% Show Segments:
colorsTable = lines(nSegments);
imSegColor = ColorSegments(segments, colorsTable);
figure;
subplot(1,2,1);
imshow(imData, 'InitialMagnification','fit'); title('Original Image');
subplot(1,2,2);
imshow(imSegColor, [], 'InitialMagnification','fit');
title({'Final Segments -  Result'});


switch (sOpts.selectObjSegmentMethod )
    case 'FewestPixels'
        nPixPerSeg = zeros(nSegments, 1);
        for iSeg = 1:nSegments
            nPixPerSeg(iSeg) = sum(segments(:) == iSeg);
        end
        [~, objSegIdx] = min(nPixPerSeg);
        mAlpha = (segments == objSegIdx);
        
    case 'UserInterface'
        % Select the object's segments by graphical interface
        [ mAlpha ] = ChooseObjectSegments(imData, segments, nSegments );
end

grayScaleIm = rgb2gray(imData);
grayScaleIm = im2double(grayScaleIm) .* im2double(mAlpha);
figure; imshow(repmat(mAlpha,[1,1,3]).* im2double(imData), 'InitialMagnification','fit');
title('Final Foreground Image');


end

