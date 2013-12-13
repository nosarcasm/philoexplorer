function checkstream( update_frequency_minutes, threshold )
% Define these variables appropriately:
mail = 'admin@tivli.com'; %Your GMail email address
password = 'RAWBrowne123'; %Your GMail password

% Then this code will set up the preferences properly:
setpref('Internet','E_mail',mail);
setpref('Internet','SMTP_Server','smtp.gmail.com');
setpref('Internet','SMTP_Username',mail);
setpref('Internet','SMTP_Password',password);
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port','465');

global t2;
t2 = timer('TimerFcn',@(x,y)checkstream_helper(threshold),'ExecutionMode','fixedRate','Period',60*update_frequency_minutes);
start(t2);

% Send the email. Note that the first input is the address you are sending the email to
emails = {'tuan@tivli.com','yasha@tivli.com','ryan@tivli.com'};
subject = 'Automated message: Streaming Alerts Active (Matlab)';
message = 'Hello! This is an automated message from Matlab to inform you that checkstream() is now measuring the difference between requested and downloaded fragments. It is also making sure backend/authenticate is online. After three unsuccessful attempts, you will be sent an e-mail alert. To turn this kind of notification off, email ryan@tivli.com.';
sendmail(emails,subject,message);

end

