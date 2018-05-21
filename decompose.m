function [ Vmask, Dmask, Smask, Rmask, Omask, Pmask, SPmask, Nmask, Zmask] = decompose( BIGASSMASK )

%% USAGE INTENSITY : INT8

Vmask = BIGASSMASK{1};
Dmask = BIGASSMASK{2};
Smask = BIGASSMASK{3};

%% RANGES TO THE REVERSED GEOCODE CITIES : DOUBLE

Rmask = BIGASSMASK{4};

%% OCEAN OR LAND : LOGICAL

Omask = BIGASSMASK{5};

%% PENETRATION AND SPEED PENETRATION : DOUBLE

Pmask  = BIGASSMASK{6};
SPmask = BIGASSMASK{7};

%% COUNTRY NUMBER MASK : INT16

Nmask = BIGASSMASK{8};

%% ZONE TYPE MASK : INT8

Zmask = BIGASSMASK{9};

end
