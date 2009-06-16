h1 { 'Please login' };

if (c->stash->{message}) {
    with { style => {'background-color' => '#ff5555', color => '#ffffff', 'font-weight' => 'bold', padding => '4px'} }
    div { c->stash->{message} };
}

br;
br;

print RAW c->stash->{form}->render;

br;
br;

div {
    print OUT 'Other options:';
    ul {
        li {
            print OUT 'I forgot my password. ';
            # with { href => c->uri_for(c->controller->action_for('forgot_password')) }
            with { href => c->uri_for('Login::forgot_password') }
            a { 'help me' };
        };
        li {
            print OUT "I don't have a login.";
            # with { href => c->uri_for(c->controller->action_for('register')) }
            # with { href => c->uri_for(c->action('register')) }
            with { href => c->uri_for('Login::register') }
            a { 'register' };
        };
    };
};
