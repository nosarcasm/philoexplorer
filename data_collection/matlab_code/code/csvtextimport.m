function [ output_table ] = csvtextimport( input_filename, num_fields )
%csvtextimport.m - get text files into matlab that are csv

fid = fopen(input_filename);
preg_match = '%q';
preg_string = '';
for i=1:num_fields;
    preg_string = horzcat(preg_string, preg_match);
end
output_cells = textscan(fid,preg_string,'delimiter',',','EndOfLine','\n');
output_table = horzcat(output_cells{1,:});
fclose(fid);
end