% caras = LeerCaras();
% s = size(caras);
% for i= 1:s(1,2)
%     figure;
%     imagen = caras{i};
%     red = imagen(:,:,1);
%     green = imagen(:,:,2);
%     
%     redGreen = double(red) ./ double(green);
%     v = Histograma(redGreen);
%     blue = imagen(:,:,3);
%     v2 = Histograma(blue);
% end

counter = 0;


start();