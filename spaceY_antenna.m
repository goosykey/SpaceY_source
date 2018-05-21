function [ diameter, sqlength, gain, masscoef ] = spaceY_antenna( subarrays, numelem )
%SPACEY_GAIN Summary of this function goes here
%   Detailed explanation goes here

elsize = 0.0136; % m <- 1/2 wavelength
gain1db = 6; % dB <- Nikita
M_pow = 106 / (1.53*1.5) / 4300 * 88/136; % kg/(m^2*W) % 0.85 mass perfection

l_sub = sqrt(numelem) * elsize;

diameter = 2 * sqrt(subarrays/pi) * l_sub;
sqlength = sqrt(subarrays) * l_sub;

gain1 = 10^(gain1db/10);

gain = 10 * log10 (gain1 * numelem * subarrays);

masscoef = sqlength.^2 * M_pow; % kg per Watt of dissipated power

end

