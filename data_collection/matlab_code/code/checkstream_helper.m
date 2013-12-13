function checkstream_helper(threshold)
    % get mongo driver running
    MongoStart;
    
    % global vars
    load difference.mat;
    load tries_stream.mat;
    load last_request_success.mat;
    global dbname1;
    global dbname2;
    dbname1 = 'trackerdb.FragmentDownloaded';
    dbname2 = 'trackerdb.FragmentRequested'; 
    
    %check script
    sizeofdb1 = Mongo().count(dbname1);
    sizeofdb2 = Mongo().count(dbname2);
    
    difference_now = sizeofdb2 - sizeofdb1;
    
    [~,s] = urlread('https://backend.tivli.com/admin/');
    [~,t] = urlread('http://distro1-harvard.tivli.com:7777');
    
    if (difference_now - difference) >= threshold || s == 0 || t == 0
        tries_stream = tries_stream + 1;
        fprintf('WARNING: Streaming might be down (attempt %d)\n',tries_stream);
    else
        tries_stream = 0;
        last_request_success = datestr(now);
    end
    
    difference = difference_now;
    
    save('difference.mat','difference');
    save('last_request_success.mat','last_request_success');
    
    % send email if not working
    if tries_stream >= 3 && s == 1
        emails = {'tuan@tivli.com','yasha@tivli.com','ryan@tivli.com'};
        subject = strcat('Automated message: Fragment Difference at ', datestr(clock, 'HH:MM PM mm/DD/YYYY'));
        message = 'Hello! This is an auto alert from Matlab. The tracking server has detected a difference between requested fragments and downloaded fragments. Please check streaming as soon as possible. Disregard this message if you already know the cause of this issue. For immediate help, e-mail ryan@tivli.com. ';
        details = strcat('Difference started: ', last_request_success );
        sendmail(emails,subject,strcat(message, details));
        tries_stream = 0;
    elseif tries_stream >= 3 && s == 0
        emails = {'tuan@tivli.com','yasha@tivli.com','ryan@tivli.com'};
        subject = strcat('Automated message: Backend/Authenticate is Down at ', datestr(clock, 'HH:MM PM mm/DD/YYYY'));
        message = 'Hello! This is an auto alert from Matlab. The tracking server cannot reach backend/authenticate. Please check streaming as soon as possible. Disregard this message if you already know the cause of this issue. For immediate help, e-mail ryan@tivli.com. ';
        details = strcat('Down beginning at: ', last_request_success );
        sendmail(emails,subject,strcat(message, details));
        tries_stream = 0;
    end
    
    save('tries_stream.mat','tries_stream');
end

