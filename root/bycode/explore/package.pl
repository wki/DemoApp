#
# construct a link to a package
#
sub package_link {
    my $package = shift;
    
    with { class => 'package' }
    span {
        if (exists(stash->{package_info}->{$package})) {
            with { href => c->uri_for(c->controller->action_for('package'), $package) }
            a { $package };
        } else {
            print OUT $package;
        }
    };
}

#
# let this view run
#
sub RUN {
    my $package = stash->{package};
    my $package_info = stash->{package_info}->{$package};

    div {
        h1 { $package; };
    
        if ($package_info->{supers} && 
            ref($package_info->{supers}) eq 'ARRAY' &&
            scalar(@{$package_info->{supers}}) > 0) {
            foreach my $super (@{$package_info->{supers}}) {
                br;
                print OUT "\x{a0}" x (($super->[1] - 1) * 6);
                with { class => 'symbol' } span { " \x{22d8} " }; # <<<
                package_link $super->[0];
            }
        }
    };

    br;

    div {
        if ($package_info->{derieved} &&
            ref($package_info->{derieved}) &&
            scalar(@{$package_info->{derieved}}) > 0) {
            with { class => 'symbol' } span { " \x{22d9} " }; # >>>
            foreach my $derieved (@{$package_info->{derieved}}) {
                package_link $derieved;
                print OUT "\x{a0}\x{a0}\x{a0}";
            }
        }
    };

    br;
    br;

    foreach my $kind (qw(public private special)) {
        next if (!scalar(@{$package_info->{"${kind}_subs"}}));
        fieldset {
            legend { "\u$kind subs:" };
            ul {
                foreach my $sub (@{$package_info->{"${kind}_subs"}}) {
                    li { 
                        with { class => 'subname' }
                        span {
                            if (exists($package_info->{doc}->{$sub})) {
                                with {class => 'description'}
                                div {
                                    print RAW $package_info->{doc}->{$sub};
                                };
                            };
                            
                            span { 
                                class $package_info->{has_sub}->{$sub} ? 'own' : 'inherited';
                                $sub 
                            };
                        };
                        foreach my $defining_package (grep {$_ ne $package} @{$package_info->{sub_definition}->{$sub}}) {
                            with { class => 'symbol' } span { " \x{22d8} " }; # <<<
                            package_link $defining_package;
                        }
                    };
                }
            };
        };
    }
}

