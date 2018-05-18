
function [ font ] = LeerCaras()
%Leer un modelo (números del 0 al 9)
%  Lee un patrón entero y lo almacena en una variable 
%  Este patrón se lee blanco sobre negro (independientemente de cómo sea la
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

