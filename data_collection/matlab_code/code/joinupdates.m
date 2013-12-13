function [ all_fragments ] = joinupdates()
    numProcessors = matlabpool('size');
    if numProcessors == 0
        matlabpool
    end
    files = dir();
    fragments = cell(length(files),1);
    parfor i = 3:length(files)
        fragments{i,1} = importdata(files(i).name);
    end
    all_fragments = vertcat(fragments{:,1});

end

