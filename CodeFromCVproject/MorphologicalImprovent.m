function [ mAlpha ] = MorphologicalImprovent( mAlpha, sOpts )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

maxSeSize = sOpts.maxSeSize;

if maxSeSize ~= 0
    
    for seSize = 2:maxSeSize
        se = strel('disk', seSize);
        mAlpha = imclose(imopen(mAlpha,se),se);
    end
end

end

