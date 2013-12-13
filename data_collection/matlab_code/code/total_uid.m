% timecutoff.m 

function [ output_shows ] = total_uid( input_shows )
%dailyusers function

users_day=sortrows(input_shows,1);

n=length(users_day);
tally=0;
for i=1:(n-1) 
    if strcmp(users_day{i,1},users_day{i+1,1})
        tally=tally+1;
    end 
end 

output_shows=tally;

