function [output] = loaddata( filename )
    output = importdata(filename);
    fprintf('Loaded %s\n', filename);
end

