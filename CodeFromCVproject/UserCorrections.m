function  [mAlpha, stopCond, mCorrectFore, mCorrectBack] = UserCorrections(mAlpha,imData, mCorrectForePrev, mCorrectBackPrev, correctMethod)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here



figure;
subplot(1,2,1);
imshow(imData, 'InitialMagnification','fit'); title('Original Image');
subplot(1,2,2);
imshow(repmat(mAlpha,[1,1,3]).*imData, 'InitialMagnification','fit'); title('Current Foreground Image');



% message = sprintf('Left click and hold to begin drawing.\nSimply lift the mouse button to finish');
% msgbox(message);

title({'If you wish to mark FOREGROUND Correction'  'then click move move ,otherwise just double click'});
% If you want to corrrect, drag mouse. Press Enter to finish
switch correctMethod
    case 'Polygon';
        hMark = impoly(gca, 'Closed', true);
    case 'freehand'
        hMark = imfreehand(gca, 'Closed', true);
end
mCorrectFore = hMark.createMask();
hMark.setColor('g');


% message = sprintf('Left click and hold to begin drawing.\nSimply lift the mouse button to finish');
% uiwait(msgbox(message));

% TODO: 1.Multiple Choices. Press Enter to stop


title({'If you wish to mark BACKGROUND Correction' 'then click move move ,otherwise just double click'});
% If you want to corrrect, drag mouse. Press Enter to finish
switch correctMethod
    case 'Polygon';
        hMark = impoly(gca, 'Closed', true);
    case 'freehand'
        hMark = imfreehand(gca, 'Closed', true);
end

mCorrectBack = hMark.createMask();
hMark.setColor('r');

stopCond = ~any(mCorrectFore(:)) & ~any(mCorrectBack(:));



% Corrections:
if ~isempty(mCorrectForePrev)
    mCorrectFore = mCorrectFore | mCorrectForePrev;
end
if ~isempty(mCorrectBackPrev)
    mCorrectBack = mCorrectBack | mCorrectBackPrev;
end

mAlpha = mAlpha & ~mCorrectBack;
mAlpha = mAlpha | mCorrectFore;


end

