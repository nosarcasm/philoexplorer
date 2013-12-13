% Splitdatetime.m 
% Usage:
%      output_nested_array = splitdatetime(input_fragments)
%      output_nested_array = splitdatetime(input_shows)
%
% Takes a list of fragments or joined shows and outputs the number of uniques by year/month/day/hour
% 
% Output is a nested array as such:
% YEAR|unique fb|unique anon|<fragments>|<MO/D/H counts array>
%
% (c) By Ryan Neff Feb 17 2012 for Tivli, Inc.

function [ output_list ] = splitdatetime( input_fragments )
    % preprocessing - fix empty cells
    empties = find(cellfun(@isempty,input_fragments(:,6)));
    input_fragments(empties,6) = {''};
    
    empties = find(cellfun(@isempty,input_fragments(:,7)));
    input_fragments(empties,7) = {''};
    
    fprintf('\nStarted doing counts of uniques\n');
    output_list = cell(1,4); %preallocate array
    fprintf('Sorting on date...\n');
    input_fragments(:,1) = num2cell(datenum(input_fragments(:,1)));
    input_fragments = sortrows(input_fragments, [1]); % sort the input - just to keep things tidy
    input_fragments(:,1) = cellstr(datestr(cell2mat(input_fragments(:,1))));
    fprintf('Parsing datetime...\n');
    [Y,MO,D,H,~,~] = datevec(datenum(input_fragments(:,1)) - 5/24); % convert input to year/mo/etc. and adjust for GMT
    [By,Iy,Jy] = unique(Y,'first'); % break down by year 
    % By is a list of years, Jy is the lookup table for By

    for i=1:length(By) % loop through years
        fprintf('Counting in year %d...\n',By(i));
        offsetY = Iy(i) - 1; %number of fragments/shows to move ahead for cur. year
        match = find(Jy==i); % index of fragments/shows that match the current year
        output_list{i,1} = By(i); %year
        output_list{i,2} = length(unique(input_fragments(match,6))); %user count fb
        output_list{i,3} = length(unique(input_fragments(match,7))); %user count anon
        output_list{i,4} = input_fragments(match,:); %fragments/shows
        [Bm,Im,Jm] = unique(MO(match),'first'); %lists months in current year
        output_list{i,5} = cell(1,4); % preallocate months
        
        
        for j=1:length(Bm) % loop through months in current year
            fprintf('Counting in month %d...\n',Bm(j));
            offsetM = Im(j) - 1;
            matchM = find(Jm==j) + offsetY; % index of fragments/shows that match the current month
            output_list{i,5}{j,1} = Bm(j); % month
            output_list{i,5}{j,2} = length(unique(input_fragments(matchM,6))); %user count fb
            output_list{i,5}{j,3} = length(unique(input_fragments(matchM,7))); %user count anon
            output_list{i,5}{j,4} = input_fragments(matchM,:);%fragments/shows
            [Bd,Id,Jd] = unique(D(matchM),'first'); %lists days in current month
            output_list{i,5}{j,5} = cell(1,4); % preallocate days
            
            
            for k=1:length(Bd) % loop through days in current month
                fprintf('Counting in day %d...\n',Bd(k));
                offsetD = Id(k) - 1;
                matchD = find(Jd==k) + offsetM + offsetY; % index of fragments/shows that match the current day
                output_list{i,5}{j,5}{k,1} = Bd(k); % day
                output_list{i,5}{j,5}{k,2} = length(unique(input_fragments(matchD,6))); %user count fb
                output_list{i,5}{j,5}{k,3} = length(unique(input_fragments(matchD,7))); %user count anon
                output_list{i,5}{j,5}{k,4} = input_fragments(matchD,:); %fragments/shows
                [Bh,Ih,Jh] = unique(H(matchD),'first'); %lists hours in current day
                output_list{i,5}{j,5}{k,5} = cell(1,4); % preallocate hours
                
                for m=1:length(Bh) % loop through hours in current day
                    offsetH = Ih(m) - 1;
                    matchH = find(Jh==m) + offsetD + offsetM + offsetY; % index of fragments/shows that match the current hour
                    output_list{i,5}{j,5}{k,5}{m,1} = Bh(m); %hour
                    output_list{i,5}{j,5}{k,5}{m,2} = length(unique(input_fragments(matchH,6))); %user count fb
                    output_list{i,5}{j,5}{k,5}{m,3} = length(unique(input_fragments(matchH,7))); %user count anon
                    output_list{i,5}{j,5}{k,5}{m,4} = input_fragments(matchH,:); %fragments/shows
                end % end hour loop
            end % end day loop
        end % end month loop
    end % end year loop
    fprintf('Win! Completed splitting fragments/shows up by time.\n\n');
end % end program

