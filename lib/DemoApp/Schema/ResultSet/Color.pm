package DemoApp::Schema::ResultSet::Color;
use strict;
use warnings;

# use base 'DBIx::Class::ResultSet';
use base 'DemoApp::Schema::Base::ResultSet';

sub by_id {
    my $self = shift;
    my $id = shift;
    
    return $self->find($id);
}

1;
