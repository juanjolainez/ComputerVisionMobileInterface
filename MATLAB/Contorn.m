function [ contorno ] = Contorn( imatge )
%CONTORN Summary of this function goes here
%   Detailed explanation goes here

imatge = rgb2gray(imatge);
contorno = edge(imatge,'sobel');


end

