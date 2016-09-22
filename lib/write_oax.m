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
raob_fn=[datestr(data.dt_utc,'yyyymmddHHMM'),'_',data.id,'.oax'];
fid=fopen([out_path,raob_fn],'wt');

oax_data = [data.pres,data.h,data.temp,data.dwpt,data.wdir,data.wspd];

%write header
fprintf(fid,['%%TITLE%%',10]);
fprintf(fid,[station_name,'-',data.id,'   ',datestr(data.dt_utc,'yymmdd'),'/',...
    datestr(data.dt_utc,'HHMM'),'   ',...
    num2str(data.lat),'/',num2str(data.lon),10]);
fprintf(fid,['   LEVEL       HGHT       TEMP       DWPT       WDIR       WSPD',10]);
fprintf(fid,['-------------------------------------------------------------------',10]);

%write data
fprintf(fid,['%%RAW%%',10]);
fprintf(fid,'%5.2f, %5.2f, %5.2f, %5.2f, %5.2f, %5.2f\n',oax_data');
fprintf(fid,'%%END%%');

%close file
fclose(fid);

display('Success!, Saved in sounding folder')