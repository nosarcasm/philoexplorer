function update_fragment_helper()    
    % get mongo driver running
    MongoStart;
    
    % global vars
    load last_fragment_number.mat;
    global dbname;
    dbname = 'trackerdb.FragmentDownloaded';
    global limitfrag;
    limitfrag = 1000000;
    
    %update script starts here
    sizeofdb = Mongo().count(dbname); % split up requests if more than 1000000 fragments
    while sizeofdb - last_fragment > 0
        fragments = genvarname(['fragments_' datestr(clock, 'DDmmmYYYY_HHMMSS')]); % make variable + file names
        eval(['[' fragments ',last_fragment]=getfragments(dbname, last_fragment,limitfrag);']); % run updater
        fprintf('Sucessfully updated to %d fragments at %s.\n', last_fragment, datestr(clock, 'HH:MM PM'));
        save(fragments, fragments);
        clear fragments; % release system memory
    end
    save('last_fragment_number.mat','last_fragment');
end

