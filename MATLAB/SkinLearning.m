%Se toman 100 im�genes de la cara y se se�ala

c1 = imread('Caras/Cara1.png');
redGreen1 = double(c1(:,:,1)) ./ double(c1(:,:,2)+1);

c2 = imread('Caras/Cara2.png');
redGreen2 = double(c2(:,:,1)) ./ double(c2(:,:,2)+1);

c3= imread('Caras/Cara3.png');
redGreen3 = double(c3(:,:,1)) ./ double(c3(:,:,2)+1);


manos = LeerManos();
histograma = zeros(1,1201);
s = size(manos);
for i=1:s(1,2)
    imagen = manos{i};
    bn = uint8(im2bw(imagen));
    rojo = double(imagen(:,:,1) .* bn);
    verde = double(imagen(:,:,2) .* bn)+1.0;
    ratio = double(rojo ./ verde);
    s2 = size(ratio);
    for j=1:s2(1,1) 
        for k=1:s2(1,2)
            if (ratio(j,k) < 2 && ratio(j,k) > 0.8)
                histograma(1,uint32(ratio(j,k)*1000 -800 +1)) = histograma(1, uint32(ratio(j,k)*1000 -800 +1)) +1;
            end
        end
    end
end


% %Ponerlo en vector
% s = size(redGreen1);
% Vector1 = ones(1,s(1,1)* s(1,2));
% for i=1:s(1,1)
%    for j=1:s(1,2)
%        
%       if (redGreen1(i,j) < 2)                
%           Vector1((i-1)*s(1,2) + j) = redGreen1(i,j);
%       end
%       
%       
%    end
% end

