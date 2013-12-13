% timecutoff.m - Ryan / Yasha AM101

function [ output_shows ] = timecutoff( input_shows )
%timecutoff function

sort_day=sortrows(input_shows,4);
n = length(sort_day);
num = zeros(n,1);
for i=1:n
    num(i,1)=sort_day{i,4};
end
K=find(num(:,1)>=120);

output_shows = sort_day(K(1,1):n,:);
