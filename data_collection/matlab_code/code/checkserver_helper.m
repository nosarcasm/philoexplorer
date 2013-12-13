function checkserver_helper()
    % get mongo driver running
    MongoStart;
    
    % global vars
    load last_fragment_number_check.mat;
    load tries.mat;
    global dbname;
    dbname = 'trackerdb.FragmentDownloaded';
        
    %check script
    sizeofdb = Mongo().count(dbname);
    
    if last_fragment_check >= sizeofdb
        tries = tries + 1;
        fprintf('WARNING: TrackerDB might be down (attempt %d)\n',tries);
    else
        fprintf('Server is healthy. Received %d fragments.\n', sizeofdb - last_fragment_check);
        tries = 0;
    end
    
    last_fragment_check = sizeofdb;
    save('last_fragment_number_check.mat','last_fragment_check');
    
    % send email if not working
    if tries >= 3
        emails = {'tuan@tivli.com','yasha@tivli.com','ryan@tivli.com'};
        subject = strcat('Automated message: TrackerDB is Down at ', datestr(clock, 'HH:MM PM mm/DD/YYYY'));
        message = 'Hello! This is an auto alert from Matlab. The tracking server has not recorded any new fragments downloaded in the last three attempts. Please check trackerdb as soon as possible. Disregard this message if you already know the cause of this issue. For immediate help, e-mail ryan@tivli.com.';
        sendmail(emails,subject,message);
        tries = 0;
    end
    
    save('tries.mat','tries');
end

