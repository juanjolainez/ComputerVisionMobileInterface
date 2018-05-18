 bn = im2bw(resta, 0.1);
 perfil = zeros (sizeY, sizeX,3);
 numeros = zeros(1,sizeX);
 for i=1:sizeX
     encontrado = 0;
     j = 1;
     while (encontrado == 0 && j <= sizeY) 
        if (bn(i,j) == 1) 
           encontrado = 1;
           numeros(i) = j;
        end
        j = j+1;
     end
     i
 end