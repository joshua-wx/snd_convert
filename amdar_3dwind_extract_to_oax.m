function amdar_3dwind_extract_to_oax
%Joshua Soderholm, Feb 2016
%Climate Research Group, University of Queensland

%WHAT: converts bom UA02D sounding data to oax for sharppy

addpath('lib')

amdar_ffn    = 'tmp/data/kurnelltor_amdar.txt';
amdar_ffn    = 'tmp/data/kurnelltor_amdar.txt';

out_path  = 'tmp/out/';

amdar_data   = read_amdar(amdar_ffn);
amdar_fields = fieldnames(amdar_data);

%extract flight numbers and times
amdar_fl_list = cell(length(amdar_fields),1);
amdar_dt_list = zeros(length(amdar_fields),1);
for i=1:length(amdar_fields)
    tmp_field        = amdar_fields{i};
    tmp_flight       = amdar_data.(tmp_field).flight;
    amdar_fl_list{i} = tmp_flight;
    amdar_dt_list(i) = amdar_data.(tmp_field).dt_utc;
end

%% QF0144
amdar_fl   = 'QF0144'; %descending, landed at 2311, use SYDNEY_3dwind_20151215_2307.nc
amdar_idx  = find(strcmp(amdar_fl_list,amdar_fl));
amdar_dt   = amdar_dt_list(amdar_idx);
winds_ffn  = '/run/media/meso/DATA/project_data/kurnell_paper/dd_winds_100m/SYDNEY_3dwind_20151215_2307.nc';
wind_dts   = '20151215_2307';
tmp_field  = ['data',num2str(amdar_idx)];
plat       = amdar_data.(tmp_field).wlat;
plon       = amdar_data.(tmp_field).wlon;
ph         = amdar_data.(tmp_field).h;

winds_data = read_3Dwinds_profile(winds_ffn,plat,plon,ph,wind_dts);
write_oax(out_path,amdar_data.(tmp_field),amdar_data.(tmp_field).flight);
write_kml(out_path,amdar_data.(tmp_field),amdar_data.(tmp_field).flight);
write_oax(out_path,winds_data,['3D_winds_',wind_dts,'_for_amdar_',amdar_fl,'_',datestr(amdar_dt,'HHMM')]);
write_kml(out_path,winds_data,winds_data.flight);

%% QF0121
amdar_fl   = 'QF0121'; %ascending, took off at 2258, use SYDNEY_3dwind_20151215_2301.nc
amdar_idx  = find(strcmp(amdar_fl_list,amdar_fl));
amdar_dt   = amdar_dt_list(amdar_idx);
winds_ffn  = '/run/media/meso/DATA/project_data/kurnell_paper/dd_winds_100m/SYDNEY_3dwind_20151215_2301.nc';
wind_dts   = '20151215_2301';
tmp_field  = ['data',num2str(amdar_idx)];
plat       = amdar_data.(tmp_field).wlat;
plon       = amdar_data.(tmp_field).wlon;
ph         = amdar_data.(tmp_field).h;

winds_data = read_3Dwinds_profile(winds_ffn,plat,plon,ph,wind_dts);
write_oax(out_path,amdar_data.(tmp_field),amdar_data.(tmp_field).flight);
write_kml(out_path,amdar_data.(tmp_field),amdar_data.(tmp_field).flight);
write_oax(out_path,winds_data,['3D_winds_',wind_dts,'_for_amdar_',amdar_fl,'_',datestr(amdar_dt,'HHMM')]);
write_kml(out_path,winds_data,winds_data.flight);

%% QF0860
amdar_fl   = 'QF0860'; %ascending, took of at 2256, use SYDNEY_3dwind_20151215_2255.nc
amdar_idx  = find(strcmp(amdar_fl_list,amdar_fl));
amdar_dt   = amdar_dt_list(amdar_idx);
winds_ffn  = '/run/media/meso/DATA/project_data/kurnell_paper/dd_winds_100m/SYDNEY_3dwind_20151215_2255.nc';
wind_dts   = '20151215_2255';
tmp_field  = ['data',num2str(amdar_idx)];
plat       = amdar_data.(tmp_field).wlat;
plon       = amdar_data.(tmp_field).wlon;
ph         = amdar_data.(tmp_field).h;

winds_data = read_3Dwinds_profile(winds_ffn,plat,plon,ph,wind_dts);
write_oax(out_path,amdar_data.(tmp_field),amdar_data.(tmp_field).flight);
write_kml(out_path,amdar_data.(tmp_field),amdar_data.(tmp_field).flight);
write_oax(out_path,winds_data,['3D_winds_',wind_dts,'_for_amdar_',amdar_fl,'_',datestr(amdar_dt,'HHMM')]);
write_kml(out_path,winds_data,winds_data.flight);
keyboard



