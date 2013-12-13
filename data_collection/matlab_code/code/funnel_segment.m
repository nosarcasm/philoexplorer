%% load fresh data - this will give an error if it isn't up to date!

% specify current date for data retrieval
filedate = datestr(now,'mmddyy');

% go to recurly folder, load recurly data
cd /home/tivli/Desktop/tivlianalytics_current/tivlianalytics/recurly;
expired = csvtextimport(['expired_' filedate '.csv'],17);
live = csvtextimport(['live_' filedate '.csv'],17);
trial = csvtextimport(['trial_' filedate '.csv'],17);

% go to django folder, load django data
cd ..
cd django/
auth_user = csvtextimport(['auth_user_' filedate '.csv'],11);

% get mongodb data
MongoStart;
all_users_list = getusers('trackerdb.StartSuccess',0,0);

% shift columns around from mongodb
all_users_list(:,6) = all_users_list(:,2);
all_users_list(:,7) = all_users_list(:,3);
all_users_list(:,5) = all_users_list(:,1);
all_users_list(:,1) = all_users_list(:,4);

% break up mongodb activity by date and time
funnel_start_success = splitdatetime(all_users_list);
pivotmar = funnel_start_success{2,5}{3,5}(:,4);
pivotfeb = funnel_start_success{2,5}{2,5}(:,4);
pivotdec = funnel_start_success{1,5}{2,5}(:,4);
pivotjan = funnel_start_success{2,5}{1,5}(:,4);
dailymar = funnel_start_success{2,5}{3,5}(:,3);
dailyfeb = funnel_start_success{2,5}{2,5}(:,3);
dailydec = funnel_start_success{1,5}{2,5}(:,3);
dailyjan = funnel_start_success{2,5}{1,5}(:,3);
pivotusers = vertcat(pivotdec, pivotjan, pivotfeb, pivotmar);
dailyusers = vertcat(dailydec, dailyjan, dailyfeb, dailymar);
allusers = vertcat(pivotusers{1,:});

%% bottom part of funnel data
% weekly counts - anon, fb, live, trial, previous
for i=7:length(pivotusers)
    vertusers = vertcat(pivotusers{(i-6):i,1});
    
    empties = find(cellfun(@isempty,vertusers(:,3))); 
    vertusers(empties,3) = {''};
    count = length(unique(vertusers(:,3)));%anon
    pivotusers{i,2} = count; % weekly anonymous
    
    empties = find(cellfun(@isempty,vertusers(:,2))); 
    vertusers(empties,2) = {''};
    count = length(unique(vertusers(:,2))); %facebook
    pivotusers{i,3} = count; % weekly facebook (all)
    
    % weekly recurly funnel
    users_fb = unique(vertusers(:,2));
    num_live = 0;
    num_trial = 0;
    num_expired = 0;
    for k=1:size(live,1)
        index = find(all(strcmp(live(k,2),users_fb(:,1)),2)); % live
        if isempty(index) == 0
            num_live = num_live+1;
        end
    end
    for k=1:size(trial,1)
        index = find(all(strcmp(trial(k,2),users_fb(:,1)),2)); % trial
        if isempty(index) == 0
            num_trial = num_trial+1;
        end
    end
    for k=1:size(expired,1)
        index = find(all(strcmp(expired(k,2),users_fb(:,1)),2)); % previous
        if isempty(index) == 0
            num_expired = num_expired+1;
        end
    end
    pivotusers{i,4} = num_live; % weekly subscribers active
    pivotusers{i,5} = num_trial; % weekly trials active
    pivotusers{i,6} = num_expired; % weekly previous subscribers active
end

% daily counts - anon, fb, live, trial, previous
pivotusers(:,8) = dailyusers; % daily anonymous
for i=1:length(pivotusers)
    vertusers = pivotusers{i,1};
    empties = find(cellfun(@isempty,vertusers(:,2))); 
    vertusers(empties,2) = {''};
    count = length(unique(vertusers(:,2))); %facebook
    pivotusers{i,9} = count; % daily facebook (all)
    
    % daily recurly funnel
    users_fb = unique(vertusers(:,2));
    num_live = 0;
    num_trial = 0;
    num_expired = 0;
    num_live_sessions = 0;
    num_trial_sessions = 0;
    num_expired_sessions = 0;
    for k=1:size(live,1)
        index = find(all(strcmp(live(k,2),users_fb(:,1)),2)); % live
        index2 = find(all(strcmp(live(k,2),vertusers(:,2)),2)); % live sessions
        if isempty(index) == 0
            num_live = num_live+1;
        end
        if isempty(index2) == 0
            num_live_sessions = num_live_sessions + 1;
        end
    end
    for k=1:size(trial,1)
        index = find(all(strcmp(trial(k,2),users_fb(:,1)),2)); % trial
        index2 = find(all(strcmp(trial(k,2),vertusers(:,2)),2)); % trial sessions
        if isempty(index) == 0
            num_trial = num_trial+1;
        end
        if isempty(index2) == 0
            num_trial_sessions = num_trial_sessions + 1;
        end
    end
    for k=1:size(expired,1)
        index = find(all(strcmp(expired(k,2),users_fb(:,1)),2)); % previous
        index2 = find(all(strcmp(expired(k,2),vertusers(:,2)),2)); % trial sessions
        if isempty(index) == 0
            num_expired = num_expired+1;
        end
        if isempty(index2) == 0
            num_expired_sessions = num_expired_sessions + 1;
        end
    end
    
    pivotusers{i,10} = num_live; % weekly subscribers active
    pivotusers{i,11} = num_trial; % weekly trials active
    pivotusers{i,12} = num_expired; % weekly previous subscribers active
    
    % session counts - % weekly counts - anon, fb, live, trial, previous
    table_size = size(vertusers,1);
    pivotusers{i,14} = table_size - size(find(cellfun(@isempty,vertusers(:,3))),1); % anon sessions
    pivotusers{i,15} = table_size - size(find(cellfun(@isempty,vertusers(:,2))),1); % fb sessions
    pivotusers{i,16} = num_live_sessions; % live sub 
    pivotusers{i,17} = num_trial_sessions; % trial sub
    pivotusers{i,18} = num_expired_sessions; % prev sub
    pivotusers{i,19} = datestr(vertusers(1,1),2);
end

pivotusers = pivotusers';