function [ numPerfil ] = DefinirPerfil( resta )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    bn = im2bw(resta, 0.1);
    s = size(resta);
     numPerfil = zeros(1,s(1,2));
     for i=1:s(1,2)
         encontrado = 0;
         j = 1;
         while (encontrado == 0 && j <= s(1,1)) 
            if (bn(j,i) == 1) 
               encontrado = 1;
               numPerfil(1,i) = j;
            end
            j = j+1;
         end

     end
     

end

