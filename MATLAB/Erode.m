function [ eroded, se ] = Erode( original )
%ERODE Summary of this function goes here
%   Detailed explanation goes here
        s = size(original);
        fentFiltre=1
        area_filtre = double(int32((s(1,1) * s(1,2))*0.0000025));
        areafiltro = 1;
        se = strel('diamond',area_filtre);
        filtrefet= 1;
        eroded = imopen(original,se);
        openfet = 1;
        figure('Name', 'Eroded'), imshow(eroded);
end

