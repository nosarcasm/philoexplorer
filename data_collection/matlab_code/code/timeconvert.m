% timeconvert.m 

function [ output_shows ] = timeconvert( input_shows )
%timeconvert function

n = length(input_shows);
output_shows = input_shows;

for i=1:n
    time_cell = textscan(input_shows{i,4},'%s %*[^\n]');
    time_array = str2num(strrep(char(time_cell{1,1}),':',', '));
    time_hours = time_array(1,1) + time_array(1,2)./60 + time_array(1,3)./3600;
    output_shows{i,7} = time_hours;
end

