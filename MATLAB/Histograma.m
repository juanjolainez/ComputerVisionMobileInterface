function [ Vector1] = Histograma( redGreen1 )
s = size(redGreen1);
Vector1 = ones(1,s(1,1)* s(1,2));
for i=1:s(1,1)
   for j=1:s(1,2)
      if (redGreen1(i,j) < 2)                
          Vector1((i-1)*s(1,2) + j) = redGreen1(i,j);
      end  
   end
end
hist(Vector1);figure(gcf);

