function [ EPHEMERIS ] = J2circ( INITIAL_ROIU, dt, step )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

mu0 = 398600.44;
J2 = 1.7555e10;

ini = INITIAL_ROIU;

a0 = ini(1);
Om0 = ini(2);
in0 = ini(3);
u0 = ini(4);

T = 2*pi*sqrt(a0^3/mu0);
n = 2*pi/T;

t = (0:step:dt)';

EPHEMERIS = zeros(numel(t),6);
EPHEMERIS(:,1) = a0;
EPHEMERIS(:,2) = 0;
EPHEMERIS(:,5) = in0;



EPHEMERIS(:,3) = 0;
EPHEMERIS(:,4) = Om0-2*pi*J2/mu0/a0^2 * 3/2*cos(in0) .*t/T;

u = u0 + n.*t;

EPHEMERIS(:,6) = u;
EPHEMERIS(:,6) = mod(EPHEMERIS(:,6),2*pi);
EPHEMERIS = [t,EPHEMERIS];




end

