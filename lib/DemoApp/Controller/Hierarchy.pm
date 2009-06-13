package DemoApp::Controller::Hierarchy;

use strict;
use warnings;
use parent qw(Catalyst::Controller::HTML::FormFu
              DemoApp::RequireLoginController 
              DemoApp::AjaxController
              );

=head1 NAME

DemoApp::Controller::Hierarchy - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    # retrieve the structure in traversal-order
    $c->stash->{hierarchy} = [ $c->model('DB::Hierarchy')
                                 ->all() ];
}


=head1 AUTHOR

Wolfgang Kinkeldei

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
