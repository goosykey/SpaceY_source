function [ COORDS ] = sample2latlon( samp, latmap, lonmap, mapdata, distort )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

latstep = mapdata{3}; lonstep = mapdata{4};

COORDS = zeros(length(samp),2);

COORDS(:,1) = latmap(samp);
COORDS(:,2) = lonmap(samp);

if distort
    distortion = rand(length(samp),2) - 0.5;
    distortion(:,1) = distortion(:,1) * latstep;
    distortion(:,2) = distortion(:,2) * lonstep;
    COORDS = COORDS + distortion;
end

end

