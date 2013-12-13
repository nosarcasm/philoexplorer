function [ output_table ] = freefacebook(input_table, offset, header_size)
% freefacebook.m - count the number of free facebook users over time
% offset - apply an offset to the data (if necessary)
    
    % get days included in table
    [sorted_table_with_staff, start_date, ~, days] = timespan(input_table,11, header_size);
    output_table = cell(days,2);
    
    % remove staff
    index = find(strcmp(sorted_table_with_staff(:,7),'0'));
    sorted_table = sorted_table_with_staff(index,:);
    
    % do the counts
    for i=0:days
        output_table{(i+1),1} = datestr(start_date+i,2);
        output_table{(i+1),2} = size(find(datenum(sorted_table(:,11)) <= (start_date+i)),1)+offset;
    end
    
    % pivot the table
    output_table = output_table';
end

