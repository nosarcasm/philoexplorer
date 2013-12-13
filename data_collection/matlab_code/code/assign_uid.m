%ASSIGN_UID(input_shows, input_users)
%   assigns a unique UID for each client UUID (which is reset on reboot)
%   this is derived from either the facebook ID or the session cookie

function [ output_shows ] = assign_uid(input_shows, input_users)

fprintf('Starting UUID lookup...\n');
output_shows = input_shows;
num = length(output_shows);
output_shows1 = cell(num,1);
output_shows2 = cell(num,1);
output_shows3 = cell(num,1);
I=num;
num_matches = 0;

parfor k=1:I 
    index = find(all(strcmp(clear_conditional_array(i,1),show(:,2)),2));
	if isempty(index) == 1
        output_shows3{k,1} = 'no_match';
    else
        output_shows1{k,1}=input_users{index,2};
        output_shows2{k,1}=input_users{index,3};
        num_matches = num_matches + 1;
    end
end

output_shows(:,6) = output_shows1(:,1);
output_shows(:,7) = output_shows2(:,1);
output_shows(:,8) = output_shows3(:,1);

if num_matches ~= I
    fprintf('WARNING: Could not match all UUIDs to users.\n');
    fprintf('Found %d matches from %d input lines.\n\n', num_matches, I);
else
    fprintf('SUCCESS!');
end
end

