package DemoApp::Controller::Root;

use strict;
use warnings;
use parent 'DemoApp::RequireLoginController';

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config->{namespace} = '';

=head1 NAME

DemoApp::Controller::Root - Root Controller for DemoApp

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=cut

=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    
    $c->stash->{title} = 'Home';
}

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

=head2 auto

automatically set headers and footers for bycode rendering if not yet set

=cut

sub auto :Private {
    my ( $self, $c ) = @_;
    
    if (ref($c->view) =~ m{::ByCode\z}xms) {
        #
        # auto-set header and footer if not yet done
        #
        $c->stash->{yield}->{header} = 'include/topnav.pl'
            if (!exists($c->stash->{yield}->{header}));
        $c->stash->{yield}->{footer} = 'include/footer.pl'
            if (!exists($c->stash->{yield}->{footer}));
    }
    
    return 1; # will continue...
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end :ActionClass('RenderView') {}

=head1 AUTHOR

Wolfgang Kinkeldei

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
