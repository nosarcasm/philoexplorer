%start up multi-core setup (default 6 cores)
numProcessors = 8;
if numProcessors == 0
    matlabpool
end

%housekeeping
clear;
close all;
clc;

numProcessors = matlabpool('size');

% start measuring time - this should be fun!!!
tic;

% load the matlab data in (could take a while)
fprintf('Loading MATLAB data. This could take a while...\n')
load all_users_list.mat
fprintf('Loaded all users list.\n')

% array of filenames

filenames = {
    'allfragments1.mat',
    'allfragments2.mat',
    'allfragments3.mat',
    'allfragments4.mat',
    'allfragments5.mat',
    'allfragments6.mat',
    'allfragments7.mat',
    'allfragments8.mat',
    'allfragments9.mat',
    'allfragments10.mat',
    'allfragments11.mat',
    'allfragments12.mat',
    'allfragments13.mat',
    'allfragments14.mat',
    'allfragments15.mat',
    'allfragments16.mat',
    'allfragments17.mat',
    'allfragments18.mat'
    };

% initialize variables
array1 = [{}];
shows = [{}];
out_shows = [{}];
clean_shows = [{}];
funnel = [{}];

parfor(o=1:length(filenames),numProcessors)
    array1{o,1} = loaddata(filenames{o}); % load data
    shows{o,1} = joinfragments(array1{o,1}); % join fragment
    array1{o,1} = ''; % clear memory
    out_shows{o,1} = assign_uid(shows{o,1}, all_users_list); % do lookup
    clean_shows{o,1} = timecutoff(out_shows{o,1}); % delete shows less than 120 secs
end

% make list of all shows watched & networks
out_all = vertcat(out_shows{:,1});
clean_all = vertcat(clean_shows{:,1});
clean_showlist = listshows(clean_all);
clean_networklist = listnetworks(clean_all);

%funnel segment count
funnel_filtered = splitdatetime(clean_all);
funnel_not_filtered = splitdatetime(out_all);


fprintf('\n');
toc



