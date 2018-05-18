function [ resultados ] = HOGManos()
%HOGMANOS Summary of this function goes here
%   Detailed explanation goes here

manos = LeerManos();
s = size(manos);
resultados = cell(1,s(1,2));
for i=1:s(1,2)
    [hM, hA] = HOG(manos{i});
    resultados{i} = Bins(hM,hA,8);
end

