function rs92_to_oax
%Joshua Soderholm, Feb 2016
%Climate Research Group, University of Queensland

%WHAT: converts sondemonitor rs92 sounding data to oax for sharppy

addpath('../lib')
station_name = 'ccie';

out_path  = '/media/meso/DATA/phd/obs/profile/sounding/field/oax/';

data = read_sondemonitor_rs92;
write_oax(out_path,data,station_name);
