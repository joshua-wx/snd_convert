function write_netcdf(out_path,data,station_name)
%Joshua Soderholm, Feb 2016
%Climate Research Group, University of Queensland

%INPUT:
%out_path: output folder string
%title: header string, usually location/type
%data: struct containing time,lat,lon,pres,gpm,temp,dwpt,w_dir,w_spd

%WHAT:
%writes data to sounding oax format for sharppy

%% WRITE TO OAX FILE

%open file to write
raob_fn  = [station_name,'_',datestr(data.dt_utc,'yyyymmdd_HH'),'.nc'];
raob_ffn = [out_path,raob_fn];

%set data nan to -999
data.h(isnan(data.h))       = -999;
data.pres(isnan(data.pres)) = -999;
data.temp(isnan(data.temp)) = -999;
data.dwpt(isnan(data.dwpt)) = -999;
data.wdir(isnan(data.wdir)) = -999;
data.wspd(isnan(data.wspd)) = -999;

len = size(data.h,1);

%height
nccreate(raob_ffn,'height','Dimensions',{'height',len},'Datatype','double','Format','netcdf4','FillValue',-999);
ncwrite(raob_ffn,'height',data.h);
ncwriteatt(raob_ffn,'height','units','meters');

%time
nccreate(raob_ffn,'time','Dimensions',{'time',1},'Datatype','int32','Format','netcdf4');
base_time    = datenum('19700101','yyyymmdd');
time_diff_s = (data.dt_utc-base_time)*24*60*60;
ncwrite(raob_ffn,'time',time_diff_s);
ncwriteatt(raob_ffn,'time','units','seconds since 1970-01-01');

%temp
nccreate(raob_ffn,'temp','Dimensions',{'height',len},'Datatype','double','Format','netcdf4','FillValue',-999);
ncwrite(raob_ffn,'temp',data.temp);
ncwriteatt(raob_ffn,'temp','units','Celsius');

%dwpt
nccreate(raob_ffn,'dwpt','Dimensions',{'height',len},'Datatype','double','Format','netcdf4','FillValue',-999);
ncwrite(raob_ffn,'dwpt',data.dwpt);
ncwriteatt(raob_ffn,'dwpt','units','Celsius');

%pres
nccreate(raob_ffn,'pres','Dimensions',{'height',len},'Datatype','double','Format','netcdf4','FillValue',-999);
ncwrite(raob_ffn,'pres',data.pres);
ncwriteatt(raob_ffn,'pres','units','hPa');

%wdir
nccreate(raob_ffn,'wdir','Dimensions',{'height',len},'Datatype','double','Format','netcdf4','FillValue',-999);
ncwrite(raob_ffn,'wdir',data.wdir);
ncwriteatt(raob_ffn,'wdir','units','degree');

%temp
nccreate(raob_ffn,'wspeed','Dimensions',{'height',len},'Datatype','double','Format','netcdf4','FillValue',-999);
ncwrite(raob_ffn,'wspeed',data.wspd);
ncwriteatt(raob_ffn,'wspeed','units','m/s');

display(['Success!,',raob_fn,' Saved in sounding folder'])