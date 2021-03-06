function [ mano, nums, min ] = WristDetectorRobust( Brazo )
%WRISTDETECTOR Wrist Detector
%   Receive a b&n image that corresponds to a hand with/without arm
%   and it detects the wrist and returns the hand without arm

sizeBrazo = size(Brazo);
ventana = uint32(sizeBrazo(1,1) / 5);
limite = max(0,sizeBrazo(1,1)-ventana);
nums = AnchoBrazo(Brazo,ventana);

% absmin = limite;
% media = nums(s(1,1), 1) / s(1,1);  %Acumulado / total de elementos
% paro = (media-10) * ventana;
% for i=limite-1:-1:ventana+1
%     if (
%     
% end


% Data has been already set, we have to look for the row with the minimum 
% value that has num(i,3) > num(i,4) between 20 - (size -20)
min = 21;
trobat = -1;
while (trobat == -1 && min < sizeBrazo(1,1))
    if (trobat == -1 && nums(min,3) > nums(min,4)) 
       trobat = 1;
       absmin = min;
    else 
       min = min+1; 
    end
end

%min es el primer elemento que tiene m�s area arriba que abajo y es
%candidato a ser la mu�eca
%Absmin es el candidato con el ancho m�s fino

for j=min:limite
    if (nums(j,1) < nums(absmin,1) && nums(j,3) > nums(j,4)) 
        absmin = j;
        min = j;
    elseif (abs(nums(j,1)-nums(absmin,1)) <= 10) %si son similares, ajustar con tama�o imagen     
        if(nums(j,3) > nums(j,4) && ((nums(j,3) - nums(j,4)) - (nums(min,3) - nums(min,4)) > 25))
            min = j;
        end
    end
end


mano = Brazo(1:min, 1:sizeBrazo(1,2));

end

