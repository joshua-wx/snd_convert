function uywo_to_nc
%Joshua Soderholm, Feb 2016
%Climate Research Group, University of Queensland

%WHAT: converts bom UA02D sounding data to oax for sharppy

addpath('lib')
out_path     = '/home/meso/ybbn_snding/';
station_name = 'YBBN';
station_num  = 94578;
date_list    = {'20170922','20171010','20171026','20171029','20171030','20171209','20171231','20180101','20180103'};
snd_hour     = 23;

for i=1:length(date_list)
    snd_date = datenum(date_list{i},'yyyymmdd');
    data     = read_uwyo(station_num,snd_date,snd_hour);
    if ~isempty(data)
        write_netcdf(out_path,data,station_name)
    else
        disp('missing data')
        keyboard
    end
end