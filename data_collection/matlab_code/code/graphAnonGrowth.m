function [ output_users ] = graphAnonGrowth( input_users )
    close all;
    
    % preprocessing
    input_users = sortrows(input_users, [4]);
    empties = find(cellfun(@isempty,input_users(:,3)));
    input_users(empties,3) = {''};
    
    % remove dups
    [~,index,~] = unique(input_users(:,3),'first');
    output_users = input_users(index,:);
    output_users(:,6) = num2cell(1);
    output_users(:,4) = num2cell(datenum(output_users(:,4)));
    output_users = sortrows(output_users, [4]);
    output_users(:,7) = num2cell(cumsum(cell2mat(output_users(:,6)),1));
    
    %create figure
    figure;
    scatter(cell2mat(output_users(:,4)), cell2mat(output_users(:,7)));
    datetick('x',1);
end

