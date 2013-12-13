% joinfragments.m 

function [ output_table ] = joinfragments( raw_fragments )
%joinfragments(raw_fragments_table)
%   Takes RAW fragments and joins them together into a series of shows

time_frag = 5; % number of seconds per fragment
num_rows = length(raw_fragments); % size of the input table

% sort the table by the client UUID, then the time of the fragment
fprintf('Starting sort on %d fragments... \n', num_rows);
sorted_table = sortrows(raw_fragments, [5 1]);

% iterate through the fragments and find unique shows
fprintf('Finished sort. Joining fragments...\n');

title_old = '';
num_fragments = 0;
% pre-allocate for speed
output_table = cell(60000,5);
k = 0;
for i=1:num_rows
    % get the current fragment title
    title = sorted_table(i,4);
    if strcmp(title_old,title) == 0
        % add the length of the last show to the line
        if k ~= 0
            output_table{k,4} = num_fragments*time_frag; % length of show, in secs
        end
       
        % start a new show - clear out the show specific vars and change
        % title_old to the current show title
        num_fragments = 1;
        title_old = title;
        
        % create a new line in the output table, populate it
        k = k+1;
        
        output_table{k,1} = sorted_table{i,1}; % start time
        output_table{k,2} = sorted_table{i,4}; % show title
        output_table{k,3} = sorted_table{i,3}; % show channel
        output_table{k,4} = num_fragments*time_frag; % length of show, in secs
        output_table{k,5} = sorted_table{i,5}; % client UUID
    else
        num_fragments = num_fragments + 1; % add fragment
    end
end
output_table = output_table(1:k,:);

fprintf('Joined %d fragments into %d shows.\n', num_rows, k);
fprintf('Done. This was a triumph.\n\n');

end

