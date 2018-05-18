function [ imagenClosed ] = CloseRallas( imagen )
%CLOSERALLAS Summary of this function goes here
%   Detailed explanation goes here
    se2 = zeros(3,3);
    se2(3,:) = 1;
    imagenClosed = imclose(imagen,se2);

end

