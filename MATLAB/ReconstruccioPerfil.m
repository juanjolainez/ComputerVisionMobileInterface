function [ perfil ] = ReconstruccioPerfil( im, numPerfil )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    s = size(im)
    for i=1:s(1,2)
        if (numPerfil(1,i) ~= 0)
            for j=numPerfil(1,i):s(1,1)
            % for j = 1:sizeY
                perfil(j,i,1) = uint8(im(j,i,1));
                perfil(j,i,2) = uint8(im(j,i,2));
                perfil(j,i,3) = uint8(im(j,i,3));
            end
        elseif (i > 1 && numPerfil(1,i-1) ~=0)
            numPerfil(1,i) = numPerfil(1,i-1);

            for j=numPerfil(1,i):s(1,1)
            % for j = 1:sizeY
                perfil(j,i,1) = uint8(im(j,i,1));
                perfil(j,i,2) = uint8(im(j,i,2));
                perfil(j,i,3) = uint8(im(j,i,3));
            end
        else
            for j=1:s(1,1)
            % for j = 1:sizeY
                 perfil(j,i,1) = uint8(0);
                 perfil(j,i,2) = uint8(0);
                 perfil(j,i,3) = uint8(0);
            end
        end
     end

end

