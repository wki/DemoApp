sub RUN {
    h1 { 'Please login' };
    
    if (stash->{message}) {
        div(style => {'background-color' => '#ff5555', color => '#ffffff', 'font-weight' => 'bold', padding => '4px'}) {
            stash->{message} 
        };
    }
    
    br;
    br;
    
    print RAW stash->{form}->render;
    
    br;
    br;
    
    div {
        print OUT 'Other options:';
        ul {
            li {
                print OUT 'I forgot my password. ';
                a(href => c->uri_for('Login::forgot_password')) { 'help me' };
            };
            li {
                print OUT "I don't have a login.";
                a(href => c->uri_for('Login::register')) { 'register' };
            };
        };
    };
}