# hierarchy/index.pl

use Data::Dumper; $Data::Dumper::Sortkeys = 1;

sub hierarchy_level {
    ul {
        foreach my $h (@{stash->{hierarchy}}) {
            li {$h->name};
        }
    };
}

sub RUN {
    h1 {"hierarchy"};
    
    #with {id => 'hierarchy'} div {
    #    hierarchy_level(stash->{hierarchy});
    #}
    
    pre { Data::Dumper->Dump([stash->{hierarchy}],['hierarchy']) };
}
