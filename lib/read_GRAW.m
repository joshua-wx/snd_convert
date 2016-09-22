function data = read_GRAW(graw_ffn,flight_name,flight_time)
%Nicholas McCarthy, Sept 2016
%Climate Research Group, University of Queensland

% WHAT:
%read thermodynamic data of a sounding from a .csv file (e.g.,
%digitalsonde2014112700Z_A4530200_ptu.csv) 

%% init
data = struct;
addpath('../shared_lib')

%read offsets from config file
%config_in_fn  = 'etc/rs92.config';
%config_out_fn = 'etc/config.mat';
%read_config(config_in_fn,config_out_fn);
%load(config_out_fn);

%open ptu file
%ptu_ffn  = [in_path,ptu_fn];


%check files exist
if exist(graw_ffn,'file')~=2; display([graw_ffn,' does not exist']); return; end

%% read


%load ptu
fid=fopen(graw_ffn);
raw_data = textscan(fid,'%f%f%f%f%f%f%f%f%f','Headerlines',1,'MultipleDelimsAsOne',1); %ptu_data=ptu_data{1};
fclose(fid);

%% process ptu

%extract ptu data
graw_pres=raw_data{2}; graw_gpm=raw_data{7}; 
graw_temp=raw_data{3}; graw_relh=raw_data{4};
graw_wspd=raw_data{5}; graw_wdir=raw_data{6};
graw_lons=raw_data{8}; graw_lats=raw_data{9};

%  Currently no offsets
%     %apply offsets
%     temp_offset  = obs_temp-snd_temp;
%     relh_offset  = obs_relh-snd_relh;
%     pres_offset  = obs_pres-snd_pres;
%     graw_pres = graw_pres + pres_offset;
%     graw_temp = graw_temp + temp_offset;
%     graw_relh = graw_relh + relh_offset;

%mask ptu_relh
gt_100_mask = graw_relh>100;
graw_relh(gt_100_mask) = 100;

% offset gtck_gpm by flight height
graw_gpm = graw_gpm + 2;

%mask
mask = graw_gpm>=0;
graw_pres = graw_pres(mask);
graw_temp = graw_temp(mask);
graw_relh = graw_relh(mask);
graw_gpm  = graw_gpm(mask);



%calc dwpt
graw_dwpt = calc_dwpt(graw_relh,graw_temp);

%calc wind in m/s
graw_wspd = graw_wspd*0.51444444444;



%% save to struct

data.id      = flight_name;
data.dt_utc  = flight_time;
data.lat     = graw_lats(1);
data.lon     = graw_lons(1);

data.pres = graw_pres;
data.h    = graw_gpm;
data.temp = graw_temp;
data.dwpt = graw_dwpt;
data.wdir = graw_wdir;
data.wspd = graw_wspd; %m/s