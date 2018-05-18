function [ closed ] = Close( imagen, filtro )
    s = size(imagen);
    %area_filtre = double(int32((s(1,1) * s(1,2))*0.001));
    %se = strel('diamond',area_filtre);
    closed = imclose(imagen,filtro);
    figure('Name', 'Closed'), imshow(closed);

end

