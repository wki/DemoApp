use Data::Dumper;

sub RUN {
    pre {
        Data::Dumper->Dump([c->stash->{persons}],['persons']);
    };
}