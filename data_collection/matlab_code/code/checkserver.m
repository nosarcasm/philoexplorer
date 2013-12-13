function checkserver( update_frequency_minutes )
% Define these variables appropriately:
mail = 'admin@tivli.com'; %Your GMail email address
password = <your password here>; %Your GMail password

% Then this code will set up the preferences properly:
setpref('Internet','E_mail',mail);
setpref('Internet','SMTP_Server','smtp.gmail.com');
setpref('Internet','SMTP_Username',mail);
setpref('Internet','SMTP_Password',password);
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port','465');

global t1;
t1 = timer('TimerFcn',@(x,y)checkserver_helper,'ExecutionMode','fixedRate','Period',60*update_frequency_minutes);
start(t1);

% Send the email. Note that the first input is the address you are sending the email to
emails = {'tuan@tivli.com','ryan@tivli.com'};
subject = 'Automated message: TrackerDB Alerts Active (Matlab)';
message = 'Hello! This is an automated message from Matlab to inform you that checkserver() is now querying trackerdb to make sure it is receiving fragment data on a regular basis. After three unsuccessful attempts, you will be sent an e-mail alert. To turn this kind of notification off, email ryan@tivli.com.';
sendmail(emails,subject,message);

end

