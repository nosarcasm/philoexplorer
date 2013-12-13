% timeconvert.m - Ryan / Yasha AM101

function [ output_shows ] = timeconvert2( input_shows )
%timeconvert function
n = length(input_shows);
output_shows = [input_shows cell(n,1)];
fprintf('Starting conversion to absolute time on %d fragments...\n', n);

numProcessors = matlabpool('size');

time_cell = cell(1);
time_array = cell(1,3);
time_secs = 0;
parfor(i=1:n, numProcessors)
    time_cell = textscan(input_shows{i,1},'%s %*[^\n]');
    time_array = str2num(strrep(char(time_cell{1,1}),':',', '));
    time_secs = time_array(1,1) + time_array(1,2)./60 + time_array(1,3)./3600;
    output_shows{i,6} = time_secs;
end
fprintf('Completed conversion.\n');
