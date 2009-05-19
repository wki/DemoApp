package DemoApp::Controller::Explore;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head1 NAME

DemoApp::Controller::Explore - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched DemoApp::Controller::Explore in Explore.');
}


=head1 AUTHOR

Wolfgang Kinkeldei

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
