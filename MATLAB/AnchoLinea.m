function [ anchoLinea ] = AnchoLinea( linea )
%Given a binary line, returns the distance between the first and last 
%   element

x1 = find(linea, 1, 'first'); 
x2 = find(linea, 1, 'last');
anchoLinea = x2-x1;

end

