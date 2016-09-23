function data = read_3Dwinds_profile(data_ffn,plat,plon,ph,ddwind_time)
%Joshua Soderholm, Sept 2016
%Climate Research Group, University of Queensland
%
%WHAT: Extracts a vertical or custom profile from 3D wind retrival files
%produced by Alain Protat. Note: No error checking! Use at your own risk.
%
%INPUT: plat,plon,ph are 1x1 for vertical profile extraction, or 1xn for
%nonuniform profile extracton. ddwind_time (string yyyymmdd_HHMM)
%
%DATA OUT FORMAT:
%        data.data#.flight      (1x1 flight code)
%                  .dt_utc      (1x1 datetime in UTC)
%                  .id          (1x1 DUMMY bom site id)
%                  .wmo_id      (1x1 DUMMY wmo site id)
%                  .lat         (1x1 lat of lowest data point)
%                  .lon         (1x1 long of lowest data point)
%                  .elev        (1x1 elev of lowest data point)
%                  .pres        (nx1 DUMMY presure - hpa)
%                  .h           (nx1 height of amdar data - m)
%                  .temp        (nx1 DUMMY temperature - degC)
%                  .dwpt        (nx1 DUMMY dew point temperature - degC
%                  .wdir        (nx1 wind direction - degTN)
%                  .wspd        (nx1 wind speed - m/s)
%                  .wlat        (nx1 lat of amdar data)
%                  .wlon        (nx1 lon of amdar data)
%                  .wdt         (nx1 dt of  profile data)
%                  .amdar       (1x1 false for 3dwinds)
%                  .wraob       (1x1 false for 3dwinds)
%                  .ddwind      (1x1 true for 3dwinds)
%% init
data       = struct;
nc_time    = datenum(ddwind_time,'yyyymmdd_HHMM');
addpath('/home/meso/Dropbox/dev/shared_lib')

%load lat lon
nc_lon = double(ncread(data_ffn,'longitude'));
nc_lat = double(ncread(data_ffn,'latitude'));
nc_h   = double(ncread(data_ffn,'height')).*1000; %convert to m

%load wind data
nc_vx = -double(ncread(data_ffn,'vx')); nc_vx(abs(nc_vx)==999)=nan;
nc_vy = -double(ncread(data_ffn,'vy')); nc_vy(abs(nc_vy)==999)=nan;

if length(plat) == 1
    %vertical profile extraction
    profile_type = 'vertical';
    %find nearest lat lon location
    [~,lon_ind] = min(abs(nc_lon-plon));
    [~,lat_ind] = min(abs(nc_lat-plat));
    %extract profile
    profile_vx   = reshape(nc_vx(lon_ind,lat_ind,:),length(nc_h),1);
    profile_vy   = reshape(nc_vy(lon_ind,lat_ind,:),length(nc_h),1);
    profile_wlon = repmat(plon,length(profile_h),1);
    profile_wlat = repmat(plat,length(profile_h),1);
    profile_h    = nc_h;
    profile_wdt  = repmat(nc_time,length(profile_h),1); 
else
    profile_type = 'nonuniform';
    profile_vx   = zeros(length(plat),1);
    profile_vy   = zeros(length(plat),1);
    profile_h    = zeros(length(plat),1);
    profile_wlat = zeros(length(plat),1);
    profile_wlon = zeros(length(plat),1);
    profile_wdt  = zeros(length(plat),1);
    for i=1:length(plat)
        [~,lon_ind]     = min(abs(nc_lon-plon(i)));
        [~,lat_ind]     = min(abs(nc_lat-plat(i)));
        [~,h_ind]       = min(abs(nc_h-ph(i)));
        profile_vx(i)   = reshape(nc_vx(lon_ind,lat_ind,h_ind),1,1);
        profile_vy(i)   = reshape(nc_vy(lon_ind,lat_ind,h_ind),1,1);   
        profile_wlon(i) = nc_lon(lon_ind);
        profile_wlat(i) = nc_lat(lat_ind);
        profile_h(i)    = nc_h(h_ind);
        profile_wdt(i)  = nc_time;
    end
end
%mask null points
profile_mask = isnan(profile_vx) | profile_vy == isnan(profile_vy);
%convert x,y to wdir,spd
[profile_wdir,profile_wspd] = cart2compass(profile_vx,profile_vy);
profile_wdir(profile_mask)  = nan;
profile_wspd(profile_mask)  = nan;
%% output
data_id   = ['3dwinds_',profile_type,'-profile_',ddwind_time];
%lat,lon,gpm, wspd, wdir, temp
data.wspd = profile_wspd;
data.wdir = profile_wdir;
data.wlon = profile_wlon;
data.wlat = profile_wlat;
data.wdt  = profile_wdt;
data.h    = profile_h;

%header for lowest lat,lon,h
[~,lowest_ind] = min(data.h);
data.lat       = data.wlat(lowest_ind);
data.lon       = data.wlon(lowest_ind);
data.elev      = data.h(lowest_ind);
data.dt_utc    = data.wdt(lowest_ind);
%dummy data
dummy_vec   = nan(length(profile_wspd),1);
data.temp   = dummy_vec;
data.pres   = dummy_vec;
data.dwpt   = dummy_vec;
data.flight = data_id;
data.id     = data_id;
data.wmo_id = data_id;
%flag data
data.amdar = true;
data.wraob = false;
data.ddwind= false;


