function [ bins ] = Bins( hModulus, hAngle, nBins )
%BINS Puts a HOGImage into nBins with a threshold
%   Detailed explanation goes here

s = size(hModulus);
threshold = 10;
rango = ((2*pi)/nBins);
bins = zeros(1,nBins);
for i=1:s(1,1)
    for j=1:s(1,2)
        if (hModulus(i,j) > threshold)
            n = uint8(hAngle(i,j)/rango + 1); 
            if(n == 9) n = 1; end
            bins(n) = bins(n) + 1;
        end
    end
end

%normalize

bins = double(bins) ./ double((s(1,1)*s(1,2)));

end

