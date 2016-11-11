function write_oax(out_path,data,station_name)
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
raob_fn=[datestr(data.dt_utc,'yyyymmddHHMM'),'_',station_name,'.oax'];
fid=fopen([out_path,raob_fn],'wt');

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