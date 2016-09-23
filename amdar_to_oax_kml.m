function amdar_to_oax_kml
%Joshua Soderholm, Feb 2016
%Climate Research Group, University of Queensland

%WHAT: converts bom UA02D sounding data to oax for sharppy

addpath('lib')

in_ffn    = 'tmp/data/kurnelltor_amdar.txt';

out_path  = 'tmp/out/';

data   = read_amdar(in_ffn);
fields = fieldnames(data);

for i=1:length(fields)
    field_name = ['data',num2str(i)];
    write_oax(out_path,data.(field_name),data.(field_name).flight);
    write_kml(out_path,data.(field_name),data.(field_name).flight)
end

