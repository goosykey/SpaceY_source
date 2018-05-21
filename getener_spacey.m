function [ Pout, Nsub] = getener_spacey( h, AS_gain, sub_gain, crosscover, br, tau, SESDATA, SESCOORD, SESBEG, jd, XYZsatorPOI )
%function [ NS, DS, SS, Pout, NSd, DSd, SSd ] = getener( a, e, om, Om, in, u, SESDATA, SESCOORD, utc )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

global test1

deg = pi/180;
R0 = 6378.14;
sector = 40.46*deg;

c = 3e5; % speed of light km/s
f_down = 11e9; %Hz
f_up = 14e9; % Hz

losses_km = 0.07;
losses_km_up = 0.04;

SNR_m = 24; % down from 27
Gain_AT_m = sub_gain;

k = 1.381*1e-23;
T = 500;
N0 = 10*log10(k*T);

Losses_tech = -3.9; % down from -7.9

C_R=1./2; % coderate
K_CP=1+1./4; % cyclic preffix

bitrate_m = br;

vtau = tau;
dtau = tau;
stau = tau;

utcsec = ceil(mod(jd-0.5,1) * 86400);
SESUTCSEC = ceil(mod(SESBEG-0.5,1) * 86400);

INTOSESSION = utcsec-SESUTCSEC;

SESUTCSEC(INTOSESSION(:) < 0) = NaN; % sessions not begun yet
SESUTCSEC(boolean((INTOSESSION(:) > vtau) .* (SESDATA(:,1)==1))) = NaN; % v.sessions already over
SESUTCSEC(boolean((INTOSESSION(:) > dtau) .* (SESDATA(:,1)==2))) = NaN; % d.sessions already over
SESUTCSEC(boolean((INTOSESSION(:) > stau) .* (SESDATA(:,1)==3))) = NaN; % s.sessions already over

SESDATA(isnan(SESUTCSEC(:)),:) = [];
SESCOORD(isnan(SESUTCSEC(:)),:) = [];
SESUTCSEC(isnan(SESUTCSEC(:))) = [];

sesq = length(SESDATA(:,1));

%POI = [33,-84]; % ATLANTA GA 
% lat = POI(1); lon = POI(2);
% 
% Xsat = (R0+h) * cosd(lat) * cosd(lon);
% Ysat = (R0+h) * cosd(lat) * sind(lon);
% Zsat = (R0+h) * sind(lat);

if numel(XYZsatorPOI) < 3
    lat = XYZsatorPOI(1); lon = XYZsatorPOI(2);
    
    Xsat = (R0+h) * cosd(lat) * cosd(lon);
    Ysat = (R0+h) * cosd(lat) * sind(lon);
    Zsat = (R0+h) * sind(lat);
else
    Xsat = XYZsatorPOI(1);
    Ysat = XYZsatorPOI(2);
    Zsat = XYZsatorPOI(3);
end



XYZ = repmat([Xsat Ysat Zsat], [sesq, 1]);

Sxyz = [R0.*cosd(SESCOORD(:,1)').*cosd(SESCOORD(:,2)');R0.*cosd(SESCOORD(:,1)').*sind(SESCOORD(:,2)');R0.*sind(SESCOORD(:,1)')];

Sxyz = Sxyz';


DISTANCES = sqrt(sum((XYZ-Sxyz).^2,2));
THETAS = acos(dot(XYZ-Sxyz, XYZ, 2)./DISTANCES./(R0+h));

THETAS(THETAS(:) > sector) = nan;
DISTANCES(isnan(THETAS(:))) = nan;
DISTANCES(DISTANCES(:) > 3000) = nan;
THETAS(isnan(DISTANCES(:))) = nan;

DISTANCES(isnan(DISTANCES)) = [];
THETAS(isnan(THETAS)) = [];

fs_losses = ((4*pi*DISTANCES*f_down/c).^2);
%expansion = fs_losses/min(fs_losses(~isnan(fs_losses(:))));
fs_losses = -10*log10(fs_losses); % FREE SPACE LOSSES

alpha_introp = asin(((h+R0)./(R0+20)).*sin(THETAS))-THETAS;
distance_introp = DISTANCES - (R0+20).*sin(alpha_introp)./sin(THETAS);
distance_introp(isnan(distance_introp(:))) = 20;
Losses_introp = -losses_km * distance_introp; % TROPOSPHERIC LOSSES

Gain0 = AS_gain;
Pol_losses = 10*log10(cos(THETAS));
Gain = Gain0+0.3.*Pol_losses+10.*log10(cos(THETAS)); % BORESIGHT LOSSES

PSD_m = -Gain_AT_m - Gain - fs_losses - Losses_introp - Losses_tech + N0 + SNR_m;

Ptx_m = PSD_m + 10*log10(bitrate_m*K_CP/C_R);

Ptx_m_W = 10.^(0.1.*Ptx_m);

test1 = DISTANCES;

Pout = sum(Ptx_m_W) / (1.1*crosscover);
Nsub = numel(Ptx_m_W) / (1.1*crosscover);

end

