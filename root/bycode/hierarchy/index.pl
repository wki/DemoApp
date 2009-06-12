# hierarchy/index.pl

use Data::Dumper; $Data::Dumper::Sortkeys = 1;

sub hierarchy_level {
    my $hierarchy = shift;
    return if (!$hierarchy || ref($hierarchy) ne 'ARRAY' || !scalar(@{$hierarchy}));
    
    my $level = $hierarchy->[0]->{level};
    ul {
        while (scalar(@{$hierarchy})) {
            my $h = $hierarchy->[0];
            if ($h->{level} == $level) {
                # same level -> simply draw
                li {$h->name};
                shift @{$hierarchy};
            } elsif ($h->{level} > $level) {
                hierarchy_level($hierarchy);
            } else {
                return;
            }
        }
    };
}

sub RUN {
    h1 {"hierarchy"};
    
    with {id => 'hierarchy'} div {
        hierarchy_level( [ @{stash->{hierarchy}} ] );
    }
    
    pre { Data::Dumper->Dump([stash->{hierarchy}],['hierarchy']) };
}
