function [ array_out ] = generateviewerprofile( input_fragments, list_networks, seconds_bin )

    % housekeeping
    close all;

    % fix idiocy
    if seconds_bin <= 0
        seconds_bin = 60;
    end

    % determine number of shows to filter on
    size1 = size(list_networks);
    length_networks = size1(1);

    % preallocate
    array_out = cell(length_networks,2);

    % convert to date number for plotting
    input_fragments(:,1) = num2cell(datenum(input_fragments(:,1)));
    input_fragments = sortrows(input_fragments,[1]);

    for i=1:length_networks
        index = find(strcmp(input_fragments(:,3),list_networks{i,1}));
        array = input_fragments(index,:);
        array_out{i,1} = array;
        % figure out which hours to plot - should be first five hours in array
        % (lazy method - improve this)
        [~,~,~,h,~,~] = datevec(cell2mat(array(:,1)));
        [bu,iu,~] = unique(h);
        figure;
        % lazy man's time subtraction - off by about 20 seconds-ish :P
        hist(cell2mat(array(2:iu(5),1)) - 5/24,(bu(5)-bu(1))*3600/seconds_bin);
        array_out{i,2} = histc(cell2mat(array(2:iu(5),1)) - 5/24,(bu(5)-bu(1))*3600/seconds_bin);
        datetick('x',13)
        title(list_networks{i,1});
        xlabel('Time (EST)');
        ylabel(['Number of fragments per ' num2str(seconds_bin) ' seconds']);
        grid;
        legend(datestr(cell2mat(array(1,1)) - 1,2));
        eval(['print -r600 -dpng ' list_networks{i,1}{1,1}]);
    end
end

