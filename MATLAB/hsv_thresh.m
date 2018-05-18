function [ imagen ] = hsv_thresh( rgb )
%HSV_THRESH Summary of this function goes here
%   Detailed explanation goes here


hsv = rgb2hsv(rgb);
s = size(rgb);
 for i=1:s(1,1)
    for j=1:s(1,2)
        if (hsv(i,j,1) >= 0 && hsv(i,j,1) <= 0.60)
            imagen(i,j) = 1;
        else
            imagen(i,j) = 0;
        end
    end
 end
end

