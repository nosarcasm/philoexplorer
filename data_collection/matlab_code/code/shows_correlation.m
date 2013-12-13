% shows_correlation.m 

function [ output_array ] = shows_correlation( input_list, input_show_events, num)
% shows_correlation - list the shows watched by users that watch other
% shows - takes the top # of shows from the input list specified by num

numProcessors = matlabpool('size');

output_array = cell(2);
output_array2 = cell(2);
output_array3 = cell(2);
num_list = length(input_list);

if num_list < num
    input_list = input_list(1:num_list,:);
else
    input_list = input_list(1:num,:);
end

%pre-processing
for i=1:length(input_show_events)
    if cellfun(@isempty,input_show_events(i,6)) == 1
        input_show_events{i,6} = input_show_events{i,7};
    end
end
% preprocessing - fix empty cells
empties = find(cellfun(@isempty,input_show_events(:,6)));
input_show_events(empties,6) = {''};

% filter all users that watched a particular show
fprintf('Starting filtering by show...\n');
parfor(i=1:num,numProcessors)
    % read the show from input list
    show = char(input_list{i,1});
    fprintf('\nFiltering for %s...\n', show);
    
     % filter out the first show from the list
    index = find(all(strcmp(input_list{i,1},input_show_events(:,2)),2));
    users_list = input_show_events(index, :);
    users_list = unique(users_list(:,6));
    num_users = size(users_list);
    num_users = num_users(1);
    
    fprintf('Found %d users for %s. Getting shows list...\n', num_users, show);
    
    % take the users list and find all of the shows that they watched
    users_show_list = {};
    
    for j=1:num_users
        % find what shows they watched and add that to the users show list
        index2 = find(all(strcmp(users_list(j,1),input_show_events(:,6)),2));
        users_show_list = [users_show_list; input_show_events(index2,:)];
    end
    
    % Count the number of shows watched (conditional probability)
    row_in_list = length(users_show_list);
    fprintf('Filtered %d show events for users that also watched %s. Listing shows...\n', row_in_list, show);
    count_users_show_list = listshows(users_show_list);
    
    % add the conditional users list to the output array
    fprintf('Adding %s to array...\n', show);
    output_array{i,1} = show;
    output_array2{i,1} = num_users;
    output_array3{i,1} = count_users_show_list;
end
output_array(:,2) = output_array2(:,1);
output_array(:,3) = output_array3(:,1);

% done
output_array = sortrows(output_array, [-2]);
fprintf('Finished filtering by show for %d shows. Applause all around.\n\n', num_list);
end
