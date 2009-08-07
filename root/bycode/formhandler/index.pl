sub RUN {
    div {'formhandler'};
    
    print RAW stash->{form}->render();
}