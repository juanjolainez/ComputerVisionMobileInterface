function [ hogImageModulus, hogImageAngle ] = HOG( imatge )
%HOG features (Modulus, Angle) from an image
%   It can process 8 and 16 bins
    imatge = rgb2gray(imatge);
    sobel = [-1 -2 -1; 0 0 0; 1 2 1];
    Gx = double(conv2(imatge, sobel));
    Gy = double(conv2(imatge,sobel'));
    hogImageModulus = sqrt((Gx .* Gx) + (Gy .* Gy));
    hogImageAngle = atan2(Gx ,   Gy) + pi;
    nans = find(isnan(hogImageAngle));
    hogImageAngle(nans) = 0;
end

