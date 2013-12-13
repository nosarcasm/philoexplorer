function [ sorted_table, start_date, end_date, days] = timespan(input_table, date_col, header_size)
% cumdatecount - count the number of dates previous to a certain date
% usage: 
%       input_table - the data that you wish to analyze
%       date_col    - the column in the table that contains the dates

% remove headers
table_size = size(input_table,1);
if header_size > 0
    input_table = input_table((header_size+1):table_size,:);
end

% sort the table
fprintf('Sorting on date...\n');
input_table(:,date_col) = num2cell(datenum(input_table(:,date_col)));
sorted_table = sortrows(input_table, [date_col]); 

% find the start and end dates and the number of days between
table_size = size(sorted_table,1);
sorted_table(:,date_col) = cellstr(datestr(cell2mat(sorted_table(:,date_col))));
start_date = floor(datenum(sorted_table{1,date_col}));
end_date = floor(now);
days = end_date - start_date;
end

