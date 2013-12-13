function [ output_table ] = allsubscribers( expired,trial,live,header_size )
% all subscribers - does a count of all the subscribers in recurly by date
    
    % generate date 0 time
    cur_time = datestr(0,31);

    % join them all together
    all_table = vertcat(expired((1+header_size):size(expired,1),:),trial((1+header_size):size(trial,1),:),live((1+header_size):size(live,1),:));
    
    % fix dates
    all_table(:,15) = strrep(all_table(:,15), 'UTC', '');
    all_table(:,16) = strrep(all_table(:,16), 'UTC', '');
    all_table(:,11) = strrep(all_table(:,11), 'UTC', '');
    all_table(:,12) = strrep(all_table(:,12), 'UTC', '');
    
    % set empty fields to date 0 if blank
    index = find(strcmp(all_table(:,16),''));
    all_table(index,16) = cellstr(cur_time);
    
    index = find(strcmp(all_table(:,15),''));
    all_table(index,15) = cellstr(cur_time);
    
    index = find(strcmp(all_table(:,11),''));
    all_table(index,11) = cellstr(cur_time);
    
    index = find(strcmp(all_table(:,12),''));
    all_table(index,12) = cellstr(cur_time);
        
    % get the date range for the data
    [ sorted_table, start_date, ~, days] = timespan(all_table, 15, 1); 
    
    % preallocate output table
    output_table = cell(days,7);
    
    for i=0:days
        % current date
        output_table{(i+1),1} = datestr(start_date+i,2);
        fprintf('Working on date %s... \n',datestr(start_date+i,2));
        % current subscribers (all)
            % a - select currently valid subs
            index = find(datenum(sorted_table(:,16)) >= (start_date+i));
            index2 = find(datenum(sorted_table(:,16)) == datenum(cur_time));
            current_subs = sorted_table([index;index2],:);

            % b - select started subscriptions
            index = find(datenum(current_subs(:,15)) <= (start_date+i));
            current_subs = current_subs(index,:);

            % c - remove trials currently active
            index = find(datenum(current_subs(:,12)) <= (start_date+i));
            current_subs = current_subs(index,:);
            
            % d - remove all rows that are clearly trial only
            current_subs_size = size(current_subs,1);
            
            index = find(datenum(current_subs(:,12)) ~= datenum(cur_time));
            current_not_subs = current_subs(index,:);
            
            index = find(datenum(current_not_subs(:,12)) - datenum(current_not_subs(:,16)) >= 1/24);
            current_not_subs = current_not_subs(index,:);
            
            current_subs_size = current_subs_size - size(current_not_subs,1);

        % current subscribers (did a trial/no trial)

            % find all the people who didn't do a trial
            index = find(datenum(current_subs(:,11)) == datenum(cur_time));
            current_subs_no_trial = current_subs(index,:);

            current_subs_no_trial_size = size(current_subs_no_trial,1);
            current_subs_did_a_trial_size = current_subs_size - current_subs_no_trial_size;

        % did a trial, never subscribed

            % a - find all trials that expired
            index = find(datenum(sorted_table(:,12)) <= (start_date+i));
            trials_ended = sorted_table(index,:);
            
            index2 = find(datenum(trials_ended(:,12)) ~= datenum(cur_time));
            trials_ended = sorted_table(index2,:);
            
            if ~isempty(trials_ended)
                % b - find all canceled ats that equal trial ends at
                index = find(datenum(trials_ended(:,12)) - datenum(trials_ended(:,16)) <= 1/24);
                did_a_trial = trials_ended(index,:);
            else
                did_a_trial = {};
            end

            did_a_trial_size = size(did_a_trial,1);

        % previously subscribed
          % a - find all expired accounts
            index = find(datenum(sorted_table(:,16)) <= (start_date+i));
            previous_subs = sorted_table(index,:);
            
            index2 = find(datenum(previous_subs(:,16)) ~= datenum(cur_time));
            previous_subs = sorted_table(index2,:);

            previous_subs_size = size(previous_subs,1);

        % in trial
            % a - find all trials that have started
            index = find(datenum(sorted_table(:,11)) <= (start_date+i));
            started_trials = sorted_table(index,:);
            
            index2 = find(datenum(started_trials(:,11)) ~= datenum(cur_time));
            started_trials = started_trials(index2,:);

            % b - find all trials that haven't expired yet or have no
            % expiration date
            if ~isempty(started_trials)
                index = find(datenum(started_trials(:,12)) >= (start_date+i));
                index2 = find(datenum(started_trials(:,12)) == datenum(cur_time));
                in_trial = started_trials([index;index2],:);
            else
                in_trial = {};
            end

            in_trial_size = size(in_trial,1);
            
       % put the data into the table!!
        output_table{(i+1),2} = did_a_trial_size;
        output_table{(i+1),3} = previous_subs_size;
        output_table{(i+1),4} = in_trial_size;
        output_table{(i+1),5} = current_subs_did_a_trial_size;
        output_table{(i+1),6} = current_subs_no_trial_size;
        output_table{(i+1),7} = current_subs_size;
    end
    
    % pivot result
    output_table = output_table';
end

