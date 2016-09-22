function GRAW_to_oax
%Nicholas McCarthy, Sept 2016 (Adapted from UAO2D_to_oax J. Soderholm, 2016)
%Climate Research Group, University of Queensland

%WHAT: converts bom UA02D sounding data to oax for sharppy

%Note: the GRAW .txt outputs do not currently output a date.
%Assuming a small number of conversions, just give them in array 'times'

addpath('lib')
sounding_name = 'Aspey';

times = ['201605180200','201605180400','201605180430'];

in_path   = '/home/fuego/Desktop/RawSounding/';
file_list = dir(in_path); file_list(1:2)=[];

out_path  = '/home/fuego/Desktop/OaxSounding/';
length(file_list)

for i=1:length(file_list)
    file_list(i).name
    data = read_GRAW([in_path,file_list(i).name],['Aspey' num2str(i)],datenum(times(i),'yyyymmddHHMM'));
    if ~isempty(data)
        write_oax(out_path,data,['Aspey' num2str(i)]);
    end
end