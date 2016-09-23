function data = read_amdar(data_ffn)
%Joshua Soderholm, Sept 2016
%Climate Research Group, University of Queensland
%
%WHAT:
% reads text file produced by amdar extraction website in a standard data
% struct for export in profile_convert
% http://oeb-ados-dev.bom.gov.au/adosmon/webmon/exportdata/

%DATA OUT FORMAT:
%        data.data#.flight      (1x1 flight code)
%                  .dt_utc      (1x1 datetime in UTC)
%                  .id          (1x1 DUMMY bom site id)
%                  .wmo_id      (1x1 DUMMY wmo site id)
%                  .lat         (1x1 lat of lowest data point)
%                  .lon         (1x1 long of lowest data point)
%                  .elev        (1x1 elev of lowest data point)
%                  .pres        (nx1 DUMMY presure - hpa)
%                  .h           (nx1 height of amdar data - m)
%                  .temp        (nx1 temperature - degC)
%                  .dwpt        (nx1 DUMMY dew point temperature - degC
%                  .wdir        (nx1 wind direction - degTN)
%                  .wspd        (nx1 wind speed - m/s)
%                  .wlat        (nx1 lat of amdar data)
%                  .wlon        (nx1 lon of amdar data)
%                  .wdt         (nx1 dt of  profile data)
%                  .amdar       (1x1 true for amdar)
%                  .wraob       (1x1 false for amdars)
%                  .ddwind      (1x1 false for amdars)
%% init
data       = struct;

%% read input files
fid = fopen(data_ffn);
%ID, Date_Time, Aircraft_ID,Flight_Num, Lat, Lon, Alt, Temp, Wind_Dir, Wind_Speed, DEVG 
C   = textscan(fid,'%*f %s %*s %s %f %f %f %f %f %f %*f','HeaderLines',2,'Delimiter',',');

%% extract data
raw_time   = C{1};
mat_time   = datenum(raw_time,'yyyy-mm-ddTHH:MM:SS');
raw_lat    = C{3};
raw_lon    = C{4};
raw_alt    = C{5};
raw_temp   = C{6};
raw_wdir   = C{7};
raw_wspd   = C{8};

%% find uniq flight numbers
raw_fltnums         = C{2};
[uniq_fltnums,~,ic] = unique(raw_fltnums);

%% convert alt in feet to m
raw_alt = raw_alt.*0.305;

%extract
for i=1:length(uniq_fltnums)
    %data_field name
    data_field = ['data',num2str(i)];
    %extract flight data
    %code
    data.(data_field).flight = uniq_fltnums{i};
    flt_ind    = find(ic==i);
    %time
    
    %lat,lon,gpm, wspd, wdir, temp
    data.(data_field).wspd = raw_wspd(flt_ind);
    data.(data_field).wdir = raw_wdir(flt_ind);
    data.(data_field).wlat = raw_lat(flt_ind);
    data.(data_field).wlon = raw_lon(flt_ind);
    data.(data_field).wdt  = mat_time(flt_ind);
    data.(data_field).h    = raw_alt(flt_ind);
    data.(data_field).temp = raw_temp(flt_ind);
    %header for lowest lat,lon,elv
    [~,lowest_ind]           = min(data.(data_field).h);
    data.(data_field).lat    = data.(data_field).wlat(lowest_ind);
    data.(data_field).lon    = data.(data_field).wlon(lowest_ind);
    data.(data_field).elev   = data.(data_field).h(lowest_ind);
    data.(data_field).dt_utc = data.(data_field).wdt(lowest_ind);
    %dummy data
    dummy_vec                = nan(length(raw_wspd(flt_ind)),1);
    data.(data_field).pres   = dummy_vec;
    data.(data_field).dwpt   = dummy_vec;
    data.(data_field).id     = uniq_fltnums{i};
    data.(data_field).wmo_id = uniq_fltnums{i};
    %flag data
    data.(data_field).amdar = true;
    data.(data_field).wraob = false;
    data.(data_field).ddwind= false;
end
    