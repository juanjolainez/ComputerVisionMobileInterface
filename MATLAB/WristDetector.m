function [ mano ] = WristDetector( Brazo )
%WRISTDETECTOR Wrist Detector
%   Simple wrist detector using the histogram

hist = sum(Brazo,2);
s = size(hist);
ventana = 7;
diferencia = zeros(1,s(1,1));
for i=1:(s(1,1) - ventana -1)
    diferencia(i) = hist(i) - hist(i+ventana);
end

posWrist = find(diferencia == max(diferencia));

sizeBrazo = size(Brazo);
mano = Brazo(1:posWrist, 1:sizeBrazo(1,2));
imshow(mano);
end

