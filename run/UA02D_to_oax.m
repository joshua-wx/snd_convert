function UA02D_to_oax
%Joshua Soderholm, Feb 2016
%Climate Research Group, University of Queensland

%WHAT: converts bom UA02D sounding data to oax for sharppy

addpath('../lib')
station_name = 'ybbn';

in_path   = '/media/meso/storage/ybbn_snding_data/';
file_list = dir(in_path); file_list(1:2)=[];

out_path  = '/media/meso/storage/ybbn_snding_data-oax/';
length(file_list)

for i=1:length(file_list)
    file_list(i).name
    data = read_UA02D([in_path,file_list(i).name],true);
    if ~isempty(data)
        write_oax(out_path,data,station_name);
    end
end
