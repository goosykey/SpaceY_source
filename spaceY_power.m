function [ Pdis, Pcons, effcy, mass ] = spaceY_power( Pout, masscoef )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


effcy = 0.6 * sqrt(Pout)/100;
if effcy < 0.125
    effcy = 0.125;
end

Pcons = Pout / effcy;

if Pcons < 300
    Pcons = 300;
end

Pdis = Pcons-Pout;

mass = masscoef * Pdis;


end

