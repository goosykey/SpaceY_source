function [ coords ] = brain( latmap, lonmap, densi, mapdata, howmany )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

if howmany == 0
    coords = [];
    return
end

[M,N] = size(densi);

DENSICOL = reshape(densi,[M*N,1]);


TT = randsample(length(DENSICOL),howmany,true,DENSICOL);

[ coords ] = sample2latlon( TT, latmap, lonmap, mapdata, true );


end

