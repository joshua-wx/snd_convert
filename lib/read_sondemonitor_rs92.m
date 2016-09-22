function data = read_sondemonitor_rs92
%Joshua Soderholm, Feb 2016
%Climate Research Group, University of Queensland

% WHAT:
%read thermodynamic data of a sounding from a ptu.csv file (e.g.,
%digitalsonde2014112700Z_A4530200_ptu.csv) and wind data from a ground
%track file (e.g., groundtrack2014112700Z_A4530200.txt)

%% init
data = struct;
addpath('../../shared_lib')

%read offsets from config file
config_in_fn  = 'etc/rs92.config';
config_out_fn = 'etc/config.mat';
read_config(config_in_fn,config_out_fn);
load(config_out_fn);

%open ptu file
ptu_ffn  = [in_path,ptu_fn];
gtck_ffn = [in_path,grck_fn];

%check files exist
if exist(ptu_ffn,'file')~=2; display([ptu_ffn,' does not exist']); return; end
if exist(gtck_ffn,'file')~=2; display([gtck_ffn,' does not exist']); return; end

%% read

%load ptu
fid=fopen(ptu_ffn);
ptu_data = textscan(fid,'%s','Delimiter','/n'); ptu_data=ptu_data{1};
fclose(fid);

%load gtck
fid=fopen(gtck_ffn);
gtck_data = textscan(fid,'%s','Delimiter','/n'); gtck_data=gtck_data{1};
fclose(fid);

%% process ptu

%extract ptu data
ptu_pres=[]; ptu_gpm=[]; ptu_temp=[]; ptu_relh=[];
for i=1:length(ptu_data)
    %read columns
    t_data=textscan(ptu_data{i},'%f,%f,%f,%f,%f,%f,%f %*f');
    %extract columns
    t_pres=t_data{2};
    t_temp=t_data{3};
    t_relh=t_data{4};
    t_gpm=t_data{5};
    %collate
    ptu_pres=[ptu_pres;t_pres]; ptu_temp=[ptu_temp;t_temp]; ptu_relh=[ptu_relh;t_relh]; ptu_gpm=[ptu_gpm;t_gpm]; 
end

%apply offsets
temp_offset  = obs_temp-snd_temp;
relh_offset  = obs_relh-snd_relh;
pres_offset  = obs_pres-snd_pres;
ptu_pres = ptu_pres + pres_offset;
ptu_temp = ptu_temp + temp_offset;
ptu_relh = ptu_relh + relh_offset;

%mask ptu_relh
gt_100_mask = ptu_relh>100;
ptu_relh(gt_100_mask) = 100;

%mask
mask = ptu_gpm>0;
ptu_pres = ptu_pres(mask);
ptu_temp = ptu_temp(mask);
ptu_relh = ptu_relh(mask);
ptu_gpm  = ptu_gpm(mask);

%% process ground track data

%extract data
gtck_lat = []; gtck_lon = []; gtck_gpm = []; gtck_time = [];
for i=1:length(gtck_data)
    t_data = textscan(gtck_data{i},'%f%f%f%f%*f%s','Delimiter',' ','MultipleDelimsAsOne',1);
    t_lat  = t_data{2};
    t_lon  = t_data{3};
    t_gpm  = t_data{4};
    t_time = datenum([num2str(flight_date),' ',t_data{5}{1}],'yyyymmdd HH:MM:SS');
    gtck_lat=[gtck_lat;t_lat]; gtck_lon=[gtck_lon;t_lon]; gtck_gpm=[gtck_gpm;t_gpm]; gtck_time=[gtck_time;t_time];
end

%sort by time
[gtck_time,sort_ind] = sort(gtck_time);
gtck_lat   = gtck_lat(sort_ind);
gtck_lon   = gtck_lon(sort_ind);
gtck_gpm   = gtck_gpm(sort_ind);

%remove negative gpm
neg_gpm_mask = gtck_gpm<0;
gtck_time    = gtck_time(~neg_gpm_mask);
gtck_lat     = gtck_lat(~neg_gpm_mask);
gtck_lon     = gtck_lon(~neg_gpm_mask);
gtck_gpm     = gtck_gpm(~neg_gpm_mask);

%filter
skip      = 5;
gtck_lat  = gtck_lat(1:skip:end);
gtck_lon  = gtck_lon(1:skip:end);
gtck_time = gtck_time(1:skip:end);
gtck_gpm  = gtck_gpm(1:skip:end);

%calc dist between points
[gtck_arclen,gtck_az] = distance(gtck_lat(2:end),gtck_lon(2:end),gtck_lat(1:end-1),gtck_lon(1:end-1)); %ensure direction points correctly (into wind)
gtck_dist             = deg2km(gtck_arclen).*1000;
gtck_diff             = (gtck_time(2:end)-gtck_time(1:end-1))*60*60*24;
gtck_gpm              = gtck_gpm(2:end);

%mask by t_dist (0 and big jumps)
max_t_dist = 200; %m
mask = false(length(gtck_dist),1);
mask(gtck_dist>0 | gtck_dist<max_t_dist) = true;
gtck_dist = gtck_dist(mask);
gtck_az   = gtck_az(mask);
gtck_diff = gtck_diff(mask);
gtck_gpm  = gtck_gpm(mask);

%calc winds
gtck_wspd     = [gtck_dist./gtck_diff]; %convert degs into m/s using track_time
gtck_wdir     = [gtck_az]; %already in degrees from north

%% interpolate temp, relh, pres to t_gpm

intp_ptu_pres = interp1(ptu_gpm,ptu_pres,gtck_gpm,'linear');
intp_ptu_temp = interp1(ptu_gpm,ptu_temp,gtck_gpm,'linear');
intp_ptu_relh = interp1(ptu_gpm,ptu_relh,gtck_gpm,'linear');


% offset gtck_gpm by flight height
gtck_gpm = gtck_gpm + flight_h;

%calc dwpt
intp_ptu_dwpt = calc_dwpt(intp_ptu_relh,intp_ptu_temp);

%% save to struct

data.id      = station_name;
data.dt_utc  = gtck_time(1);
data.lat     = flight_lat;
data.lon     = flight_lon;

data.pres = intp_ptu_pres;
data.h    = gtck_gpm;
data.temp = intp_ptu_temp;
data.dwpt = intp_ptu_dwpt;
data.wdir = gtck_wdir;
data.wspd = gtck_wspd; %m/s



function rs92_groundtrackwind_field_snding2raob

%WHAT: Designed to process the post process ground track file from sonde
%monitor into a raob wind only sounding. This allows it to be merged in
%raobs with a ptu sounding

%% READ RS-92 data
%FLIGHT LOCATION
flight_lat    = {'27.956','S'};
flight_lon    = {'152.615','E'};
%FLIGHT TIME
flight_time   = '2014271102Z';
flight_height = '120';

gps_pp_track_fn='/media/meso/DATA/phd/obs/profile/field/groundtrack2014112700Z_A4530200.txt';

%open gps track file
if exist(gps_pp_track_fn,'file')~=2; display('gps_pp_track_fn does not exist'); return; end
fid=fopen(gps_pp_track_fn);
raw_track_data = textscan(fid,'%s','Delimiter','/n'); raw_track_data=raw_track_data{1};
fclose(fid);
%extract data
track_lat = []; track_lon = []; track_gpm = []; track_time = [];
for i=1:length(raw_track_data)
    t_data=textscan(raw_track_data{i},'%f%f%f%f%*f%s','Delimiter',' ','MultipleDelimsAsOne',1);
    t_lat=t_data{2};
    t_lon=t_data{3};
    t_gpm=t_data{4};
    t_time=datenum(['01/01/0001 ',t_data{5}{1}],'dd/mm/yyyy HH:MM:SS');
    track_lat=[track_lat;t_lat]; track_lon=[track_lon;t_lon]; track_gpm=[track_gpm;t_gpm]; track_time=[track_time;t_time];
end

%sort by time
[track_time,sort_ind] = sort(track_time);
track_lat   = track_lat(sort_ind);
track_lon   = track_lon(sort_ind);
track_gpm   = track_gpm(sort_ind);

lat_step    = [0;track_lat(2:end)-track_lat(1:end-1)];
lon_step    = [0;track_lon(2:end)-track_lon(1:end-1)];



%remove negative gpm
neg_gpm_mask = track_gpm<0;
track_time   = track_time(~neg_gpm_mask);
track_lat    = track_lat(~neg_gpm_mask);
track_lon    = track_lon(~neg_gpm_mask);
track_gpm    = track_gpm(~neg_gpm_mask);

%filter
skip       = 10;
track_lat  = track_lat(1:skip:end);
track_lon  = track_lon(1:skip:end);
track_time = track_time(1:skip:end);
track_gpm  = track_gpm(1:skip:end);

%calc dist between points
[t_arclen,t_az] = distance(track_lat(1:end-1),track_lon(1:end-1),track_lat(2:end),track_lon(2:end));
t_dist          = deg2km(t_arclen).*1000;
t_diff          = (track_time(2:end)-track_time(1:end-1))*60*60*24;
t_gpm           = track_gpm(2:end);

%remove zero dist points
mask = false(length(t_dist),1);
mask(t_dist>0) = true;
t_dist = t_dist(mask);
t_az   = t_az(mask);
t_diff = t_diff(mask);
t_gpm  = t_gpm(mask);

%remove jump
max_t_dist = 200;%m
mask = false(length(t_dist),1);
mask(t_dist<max_t_dist) = true;
t_dist = t_dist(mask);
t_az   = t_az(mask);
t_diff = t_diff(mask);
t_gpm  = t_gpm(mask);

track_w_spd     = [t_dist./t_diff]; %convert degs into m/s using track_time
track_w_dir     = [t_az]; %already in degrees from north


empty_vec = ones(length(t_gpm),1).*-999;
raob_data=[empty_vec,empty_vec,empty_vec,track_w_dir,track_w_spd,t_gpm];

%% WRITE TO RAOB FILE
raob_fn=[flight_time,'_rs92_wind_only_field_raob_snding.csv'];
%open file
fid=fopen([raob_fn],'wt');
%write header
fprintf(fid,'RAOB/CSV\n');
fprintf(fid,['LAT,',flight_lat{1},',',flight_lat{2},'\n']);
fprintf(fid,['LONG,',flight_lon{1},',',flight_lon{2},'\n']);
fprintf(fid,['ELEV,',flight_height,',M\n']);
fprintf(fid,['WMO,\n']);
fprintf(fid,'MOISTURE, RH\n');
fprintf(fid,'WIND, m/s\n');
fprintf(fid,'GPM, MSL\n');
fprintf(fid,'MISSING, -999\n');
fprintf(fid,'SORT, YES\n');
fprintf(fid,'RAOB/DATA\n');
fprintf(fid,'PRES, TEMP, TD, WIND, SPEED, GPM\n');
%write data
fprintf(fid,'%5.1f, %3.1f, %3.1f, %3.1f, %3.1f, %6.1f\n', raob_data');
%close file
fclose(fid);

display('Success!, Saved in sounding folder')


