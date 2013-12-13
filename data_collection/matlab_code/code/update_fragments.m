function update_fragments()
    %keeps running update script once an hour
    global t;
    t = timer('TimerFcn',@(x,y)update_fragment_helper,'ExecutionMode','fixedRate','Period',3600*6);
    start(t);
end

