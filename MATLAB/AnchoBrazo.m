function [ nums ] = AnchoBrazo( Brazo, ventana )
%Give 4 colums that correspond to: actualRow, Acumulated, 20up, 20down
%   Detailed explanation goes here

s = size(Brazo);
nums = zeros(s(1,1),4);


nums(1,1) = AnchoLinea(Brazo(1,:));
nums(1,2) = nums(1,1);
nums(1,3) = nums(1,1);
limite = min(ventana, s(1,1));
for i=2:limite
    nums(i,1) = AnchoLinea(Brazo(i,:));
    nums(i,2) = nums(i-1,2) + nums(i,1); 
    %nums(i,3) = nums(i,2);
end


for i=ventana+1:(s(1,1)) %for every row starting from the top
  %find x1 - x2 to determint the width of the figure in this place
  nums(i,1) = AnchoLinea(Brazo(i,:));  %Actual
  nums(i,2) = nums(i-1, 2) + nums(i,1);   %Acumulated
  nums(i,3) = nums(i,2) - nums(i-20,2); %%top20
end

nums(s(1,1),1) = AnchoLinea(Brazo(1,:));
nums(1,4) = nums(s(1,1),1);



limite = max(0,s(1,1)-ventana)

for i=limite:-1:1
    nums(i,4) = nums(i+20,2) - nums(i,2);
end





end

