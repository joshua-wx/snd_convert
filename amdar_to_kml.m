function amdar_to_oax
%Joshua Soderholm, Feb 2016
%Climate Research Group, University of Queensland

%WHAT: converts bom UA02D sounding data to oax for sharppy

addpath('lib')
station_name = 'sydney_ap';

in_ffn    = '';

out_path  = '';
length(file_list)

data   = read_amdar(in_ffn);
fields = fieldnames(data);

for i=1:length(fields)
    field_name = ['data',num2str(i)];
    write_kml(out_path,data.(field_name));
end