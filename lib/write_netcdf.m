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

nccreate(raob_ffn,'height',...
          'Dimensions',{'height',101},...
          'Format','classic')

data.h(isnan(data.h)) = -999;
ncwrite(raob_ffn,'height',data.h);
ncwriteatt(raob_ffn,'height','_FillValue',-999);
ncwriteatt(raob_ffn,'height','units','meters');

ncwrite(raob_ffn,'time',); %hours since 1970-01-01
ncwriteatt(raob_ffn,'height','_FillValue',-999);
ncwriteatt(raob_ffn,'height','units','meters');



oax_data = [data.pres,data.h,data.temp,data.dwpt,data.wdir,data.wspd];

%write header
fprintf(fid,['%%TITLE%%',10]);
fprintf(fid,[' OAX   ',datestr(data.dt_utc,'yymmdd'),'/',...
    datestr(data.dt_utc,'HHMM'),10,10]);
fprintf(fid,['   LEVEL       HGHT       TEMP       DWPT       WDIR       WSPD',10]);
fprintf(fid,['-------------------------------------------------------------------',10]);

%convert nan to -9999.00
oax_data(isnan(oax_data)) = -9999;

%write data
fprintf(fid,['%%RAW%%',10]);
fprintf(fid,' %5.2f,  %5.2f,  %5.2f,  %5.2f,  %5.2f,  %5.2f\n',oax_data');
fprintf(fid,'%%END%%');

%close file
fclose(fid);

display('Success!, Saved in sounding folder')