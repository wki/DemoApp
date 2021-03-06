use Data::Dumper;

sub RUN {
    table.list.sortable._sortable {
        thead{
            trow {
                foreach my $colname (qw(id name login email)) {
                    th {$colname};
                }
            };
        };
        
        tbody {
            foreach my $person (@{stash->{persons}}) {
                trow {
                    foreach my $colname (qw(id name login email)) {
                        tcol {$person->$colname};
                    }
                };
            }
        };
    };
    
    #pre {
    #    Data::Dumper->Dump([c->stash->{persons}],['persons']);
    #};
}