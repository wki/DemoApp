package DemoApp::Controller::Persons;

use strict;
use warnings;
use parent qw(Catalyst::Controller::HTML::FormFu
              DemoApp::RequireLoginController 
              DemoApp::AjaxController
              );

=head1 NAME

DemoApp::Controller::Persons - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    my $persons = [ $c->model('DB::Person')->search({},{})->all() ];
    $c->stash->{persons} = $persons;
}


=head1 AUTHOR

Wolfgang Kinkeldei

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
