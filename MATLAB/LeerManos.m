function [ manos ] = LeerManos()
%LEERMANOS Summary of this function goes here
%   Detailed explanation goes here
n = 8;
manos = cell(1,n);
for i=1:n
    string1 = ['manos' num2str(i)];
    s = ['ManosAbiertas/' string1 '.png'];
    [imatge]=imread(s);
    manos{i} = imatge;
end

