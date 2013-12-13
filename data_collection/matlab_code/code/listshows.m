% listshows.m - Ryan / Yasha AM101 Stats Project

function [ output_shows ] = listshows( input_show_events )
%listshows - take a list of all show events and create a master show list
%of all things watched

num_rows_dup = size(input_show_events); % size of the input table
num_rows_dup = num_rows_dup(1);
if num_rows_dup == 0
    output_shows = {};
    return
end

%sort the list of shows to make the next step easy
fprintf('Starting sort on %d show events... \n', num_rows_dup);

sorted_show_events_dup = sortrows(input_show_events, [2 6]);

% remove duplicate show events by user (i.e. if they went back to watch
% some more)
fprintf('Finished sort. Removing duplicates...\n');
% preallocate memory
sorted_show_events = cell(num_rows_dup,8);
cur_user = 'none';
cur_show = 'none';
num_rows = 0;
for i=1:num_rows_dup
    cur_user_in_list = sorted_show_events_dup{i,6};
    cur_show_in_list = sorted_show_events_dup{i,2};
    if strcmp(cur_user_in_list, cur_user) == 0
        num_rows = num_rows + 1;
        cur_user = cur_user_in_list;
        cur_show = cur_show_in_list;
        sorted_show_events(num_rows,:) = sorted_show_events_dup(i,:);
    elseif strcmp(cur_user_in_list, cur_user) == 1 && strcmp(cur_show,cur_show_in_list) == 0
        num_rows = num_rows + 1;
        cur_show = cur_show_in_list;
        sorted_show_events(num_rows,:) = sorted_show_events_dup(i,:);
    else
        sorted_show_events{num_rows,4} = sorted_show_events{num_rows,4} + sorted_show_events_dup{i,4};
    end
end
sorted_show_events = sorted_show_events(1:num_rows, :);

% iterate through the fragments and find unique shows
fprintf('Finished removing duplicates. Listing shows...\n');

show_old = '';
num_times_watched = 0;
amount_time_watched = 0;
% preallocate memory
output_shows = cell(1000, 5); %preallocate at least 1000 shows
time_array = {};
pos_time_array = 1;
k = 0;
for i=1:num_rows
    % get the current show title
    show = sorted_show_events(i,2);
    if strcmp(show_old,show) == 0
        % add the number of times watched to the last show
        if k ~= 0
            pos_time_array = pos_time_array - 1;
            output_shows{k,2} = num_times_watched; % number of times watched
            output_shows{k,4} = amount_time_watched; % length of time watched by everyone, seconds
            output_shows{k,5} = time_array(1:pos_time_array, :);
        end
        
        % start a new show - clear out the show specific vars and change
        % show_old to the current show title
        num_times_watched = 1;
        amount_time_watched = sorted_show_events{i,4};
        show_old = show;
        
        % create new array to store the length of time a user watched that
        % show
        time_array = {};
        pos_time_array = 1;
        
        % add user's time watched to array
        time_array{pos_time_array,1} = sorted_show_events{i,4};
        time_array{pos_time_array,2} = sorted_show_events{i,6};
        time_array{pos_time_array,3} = sorted_show_events{i,7};
        pos_time_array = pos_time_array + 1;
           
        % create a new line in the output table, populate it
        k = k+1;
        output_shows{k,1} = show; % show title
        output_shows{k,6} = sorted_show_events(i,3); % network title
        output_shows{k,7} = sorted_show_events(i,1); % first time recorded
        output_shows{k,2} = num_times_watched; % number of times watched
        
    else
        num_times_watched = num_times_watched + 1; % increment count
        amount_time_watched = amount_time_watched + sorted_show_events{i,4};
        % add user's time watched to array
        time_array{pos_time_array,1} = sorted_show_events{i,4};
        time_array{pos_time_array,2} = sorted_show_events{i,6};
        time_array{pos_time_array,3} = sorted_show_events{i,7};
        pos_time_array = pos_time_array + 1;
    end
end
output_shows = output_shows(1:k, :);
output_shows = sortrows(output_shows, [-2]);

fprintf('Counted %d shows.\n', k);
fprintf('Winning!\n');

end

