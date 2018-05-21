function [ SESDATA, SESCOORD, SESBEG ] = gettrafficearth( jd1, dt, map, mapdata, BIGASSMASK, netdata )
%GET TRAFFIC USAGE IN ZONE
%     INPUT:
%         lat	: latitude of the central point OR 2 latitudes (rectang)
%         lon	: longitude of the central point OR 2 longitudes (rectang)
%         R     : zone radius (ignored if rectangular mode)
%         dt1	: start time (hours, [0,24) )
%         dt2	: end time (hours)
%         map	: population distribution map (not density, i.e. 'PEOPLE', NOT 'PEOPLE/sq.km')
%         mapdata : map data obtained thru 'readmap.m';
%         Vmask, Dmask, Smask : usage intensity masks
%     OUTPUT:
%         vdata, ddata, sdata : data usage


%% DECOMPOSE BIG MASK

[ Vmask, Dmask, Smask, ~, ~, Pmask, SPmask, ~, ~] = decompose( BIGASSMASK );

%% GET DAILY DISTRIBUTIONS

beginutcsec = round(mod(jd1-0.5,1)*86400);

vtau = netdata{4};
dtau = netdata{5};
stau = netdata{6};
Vminday = netdata{7};
DMBmo = netdata{8};
SGBmo = netdata{9};
bitrate_m = netdata{10};
bitrate_f = netdata{11};



% NORMAL voice daily distrib: SECONDS - SECONDS
Vdayactraw = [5 2.5 1.8 1.8 3 6 9 7.5 8.5 10 9.5 7 5]; 
Vnorm = Vminday*60/trapz(0:2*3600:24*3600,Vdayactraw);
Vdayact = Vdayactraw*Vnorm;
vqq_loc = interp1(0:2:24,Vdayact,0:1/3600:24,'spline');

% NORMAL traffic daily distrib: BYTES - SECONDS
Ddayactraw = [4 1 1 2 4 6 10 10 9 10 9 8 4]; 
Dnorm = DMBmo/30*1024^2/trapz(0:2*3600:24*3600,Ddayactraw);
Ddayact = Ddayactraw*Dnorm;
dqq_loc = interp1(0:2:24,Ddayact,0:1/3600:24,'spline');

% SPEEDY traffic daily distrib: BYTES - SECONDS
Sdayactraw = [8 6 3 2 2.5 3 4 5 6 8 10 10 8];
Snorm = SGBmo/30*1024^3/trapz(0:2*3600:24*3600,Sdayactraw);
Sdayact = Sdayactraw*Snorm;
sqq_loc = interp1(0:2:24,Sdayact,0:1/3600:24,'spline');

%% INITIALIZE MAP PARAMETERS

latlim = mapdata{1}; lonlim = mapdata{2};
latstep = mapdata{3}; lonstep = mapdata{4};

lats = latlim(1):-latstep:latlim(2);
lons = lonlim(1):lonstep:lonlim(2);

[M,N] = size(map);

[latmap, lonmap] = ndgrid(lats,lons);

%% FIT UI MASKS TO MAP SIZE & GET MODIFIED MAPS

Vmask = imresize(double(Vmask)/100,[M N],'bilinear');
Dmask = imresize(double(Dmask)/100,[M N],'bilinear');
Smask = imresize(double(Smask)/100,[M N],'bilinear');

dspeed = bitrate_m / 8; % byte/sec
sspeed = bitrate_f / 8; % byte/sec

timezonemap =  round(lonmap/15);

Vtintmap = zeros(M,N);
Dtintmap = zeros(M,N);
Stintmap = zeros(M,N);

VQQS = zeros(25,dt+1);
DQQS = zeros(25,dt+1);
SQQS = zeros(25,dt+1);

for tz = -12:12
    VQQS(tz+13,:) = qqmodify(vqq_loc,tz,dt,beginutcsec);
    DQQS(tz+13,:) = qqmodify(dqq_loc,tz,dt,beginutcsec);
    SQQS(tz+13,:) = qqmodify(sqq_loc,tz,dt,beginutcsec);
    Vtintmap(timezonemap(:)==tz) = trapz(VQQS(tz+13,:));
    Dtintmap(timezonemap(:)==tz) = trapz(DQQS(tz+13,:));
    Stintmap(timezonemap(:)==tz) = trapz(SQQS(tz+13,:));
end

Vmap = map.*Vmask.*Pmask;
Dmap = map.*Dmask.*Pmask;
Smap = map.*Smask.*SPmask; Smap(isnan(Smap)) = 0;

vdata = sum(sum(Vtintmap.*Vmap));
ddata = sum(sum(Dtintmap.*Dmap));
sdata = sum(sum(Stintmap.*Smap));

vW = vdata;
dW = ddata/dspeed;
sW = sdata/sspeed;

vNactmean = vW/dt;
dNactmean = dW/dt;
sNactmean = sW/dt;

%% FIND NUMBER OF SESSIONS BEGINNING
vQzone = vNactmean/vtau*dt;
dQzone = dNactmean/dtau*dt;
sQzone = sNactmean/stau*dt;

%% GENERATE THE SESSIONS
% smart roundation
vQzone = floor(vQzone) + (mod(vQzone,1)>rand);
dQzone = floor(dQzone) + (mod(dQzone,1)>rand);
sQzone = floor(sQzone) + (mod(sQzone,1)>rand);

SESCOORD = single([brain(latmap, lonmap, Vmap.*Vtintmap, mapdata, vQzone);brain(latmap, lonmap, Dmap.*Dtintmap, mapdata, dQzone);brain(latmap, lonmap, Smap.*Stintmap, mapdata, sQzone)]);

SESDATA = int8(zeros(vQzone+dQzone+sQzone,2));
SESDATA(1:vQzone,1) = 1;
SESDATA(vQzone+1:vQzone+dQzone,1) = 2;
SESDATA(vQzone+dQzone+1:vQzone+dQzone+sQzone,1) = 3;

begsec = int32(zeros(vQzone+dQzone+sQzone,1));

for tz = -12:12
    begsec(boolean((SESDATA(:,1)==1).*(round(SESCOORD(:,2)/15)==tz))) = randsample(dt+1,numel(begsec(boolean((SESDATA(:,1)==1).*(round(SESCOORD(:,2)/15)==tz))))...
        ,true,VQQS(tz+13,:));
    begsec(boolean((SESDATA(:,1)==2).*(round(SESCOORD(:,2)/15)==tz))) = randsample(dt+1,numel(begsec(boolean((SESDATA(:,1)==2).*(round(SESCOORD(:,2)/15)==tz))))...
        ,true,DQQS(tz+13,:));
    begsec(boolean((SESDATA(:,1)==3).*(round(SESCOORD(:,2)/15)==tz))) = randsample(dt+1,numel(begsec(boolean((SESDATA(:,1)==3).*(round(SESCOORD(:,2)/15)==tz))))...
        ,true,SQQS(tz+13,:));
    %fprintf ('%g > ',numel(begsec(boolean((SESDATA(:,1)==1).*(round(SESCOORD(:,2)/15)==tz)))));
end

%fprintf ('\n');
SESBEG = jd1 + double(begsec)/86400;

% figure
% plot(SESCOORD(:,2),SESCOORD(:,1),'o', 'MarkerSize',4)
% plot_google_map


end

