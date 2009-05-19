ul {
    foreach my $package (@{c->stash->{packages}}) {
        li {
            class 'active' if ($package eq (stash->{package} || ''));
            with { href => $c->uri_for(c->controller->action_for('package'), $package) }
            a { 
                $package 
            };
        };
    }
}