function [ result2 ] = SkinSegmentation( perfil )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
red = double(perfil(:,:,1));
green = double(perfil(:,:,2)) + 1;
result = red ./ green;
% level = graythresh(result);
% blancoNegro = im2bw(result,level);
s = size(perfil);
result2 = zeros(s(1,1),s(1,2));
% perfilsub = uint8(perfilsub);
% perfil(:,:,1) = perfil(:,:,1).* perfilsub;
% perfil(:,:,2) = perfil(:,:,2).* perfilsub;
% perfil(:,:,3) = perfil(:,:,3).* perfilsub;
% figure('Name', 'perfilFiltrado'); imshow(perfil);

%hsv = hsv_thresh(perfil);
thmin = 1.1;
thmax = 1.4;
for i=1:s(1,1)
   for j= 1:s(1,2)
      if (result(i,j) > thmin && result(i,j) < thmax) 
%       if (perfil(i,j,1) > perfil(i,j,2))
          result2(i,j) = 1;  
      end
   end
end

%result2 = result2 .*hsv;

s = size(result2);


area_filtre = double(int32((s(1,1) * s(1,2))*0.00001));
se = strel('diamond',area_filtre);
result2 = Close(result2, se);

figure('Name', 'closedEnSkin'); imshow(result2);

result2 = imfill(result2);

figure('Name', 'SkinSegmentation'); imshow(result2);

end

