function [ array_out ] = generatehistogram( input_all_fragments, seconds_bin)

    % housekeeping
    close all;
    
    % fix idiocy
    if nargin < 2
        seconds_bin = 60;
    end    
    
    % split date and times
    split_array = splitdatetime2(input_all_fragments);
    
    size_years = size(split_array);
    size_years = size_years(1);
    size_months = [];
    size_days = [];
    
    % run the histogram on the fragments of each day and then save them to
    % a folder
    for i=1:size_years
        size_months(i,1) = size(split_array{i,5},1);
        for k=1:size_months(i,1)
            size_days(k,1) = size(split_array{i,5}{k,5},1);
            for j=1:size_days(k,1)
                input_fragments = split_array{i,5}{k,5}{j,4};
                input_fragments(:,1) = num2cell(datenum(input_fragments(:,1)));
                fprintf('Starting generating histograms. Please wait...\n');
                array = input_fragments;
                
                % open a figure
                figure;
                fprintf('Generating histogram for day %s...\n',datestr(cell2mat(array(1,1)),1));
                
                % find hours in day
                [~,~,~,h,~,~] = datevec(cell2mat(array(:,1)));
                [bu,~,~] = unique(h);
       
                hist(cell2mat(array(:,1)),max(bu)*3600/seconds_bin);
                array_out{i,2} = histc(cell2mat(array(:,1)),max(bu)*3600/seconds_bin);
                datetick('x',13)
                title(['Activity for day ' datestr(cell2mat(array(1,1)),2)]);
                xlabel('Time (EST)');
                ylabel(['Number of fragments per ' num2str(seconds_bin) ' seconds']);
                grid;
                legend(datestr(cell2mat(array(1,1)),2));
                eval(['print -r600 -dpng ' datestr(cell2mat(array(1,1)),1) '_activity']);
                close;
            end
        end
    end 
end

