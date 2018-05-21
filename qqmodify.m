function [ qq_m ] = qqmodify( qq, tz, dt, beginutcsec )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

if nargin < 3
    dt = 86400;
end

if nargin < 4
    beginutcsec = 0;
end

qq_m = circshift(qq,[0,-tz*3600]);

qq_m = circshift(qq_m,[0,-beginutcsec]);

days = ceil(dt/86400);
qq_m = repmat(qq_m,1,days);
qq_m = qq_m(1:dt+1);

end

