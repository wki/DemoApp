# hierarchy/index.pl

use Data::Dumper; $Data::Dumper::Sortkeys = 1;

sub hierarchy_level {
    my $hierarchy = shift;
    return if (!$hierarchy || ref($hierarchy) ne 'ARRAY' || !scalar(@{$hierarchy}));
    
    my %expanded = map {($_ => 1)} (1);
    my $level = $hierarchy->[0]->get_column('level');
    ul {
        while (@{$hierarchy}) {
            my $h = $hierarchy->[0];
            if ($h->get_column('level') == $level) {
                # same level -> simply draw
                with {class => 'dropzone'} li { ' ' };
                li {
                    my @classes = ('draggable');
                    push @classes, 'expanded' if ($expanded{$h->id});
                    class @classes;
                    
                    print OUT $h->name;
                    
                    shift @{$hierarchy}; # drop this value

                    if (scalar(@{$hierarchy}) && $hierarchy->[0]->get_column('level') > $level) {
                        hierarchy_level($hierarchy);
                    }
                    '';
                };
            } else {
                last;
            }
        }
        # ''; # avoid latest while() result to be printed (= zero)
        with {class => 'dropzone'} li { ' ' };
    };
}

sub RUN {
    h1 {"hierarchy"};
    
    print OUT "ref(h) = " . ref(stash->{hierarchy}->[0]);
    br;
    
    with {id => 'hierarchy', class => '_hierarchy dragging'} div {
        hierarchy_level( [ @{stash->{hierarchy}} ] );
    };
    
    # pre { Data::Dumper->Dump([stash->{hierarchy}],['hierarchy']) };
}
