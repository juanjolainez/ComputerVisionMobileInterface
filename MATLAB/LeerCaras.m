
function [ font ] = LeerCaras()
%Leer un modelo (n�meros del 0 al 9)
%  Lee un patr�n entero y lo almacena en una variable 
%  Este patr�n se lee blanco sobre negro (independientemente de c�mo sea la
%  imagen)
    font = cell(1, 3);
     
    for i=1:3 
        string1 = [num2str(i)];
        s = ['Caras/Cara' string1 '.png'];
        [imatge]=imread(s);
%         level = graythresh(imatge); 
%         imatge = im2bw(imatge, level);
%         if(imatge(1,1) == 1)
%             imatge = 1 - imatge;
%         end
        font{i} = imatge;
    end
end

