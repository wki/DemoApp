package DemoApp::RequireLoginController;

use strict;
use warnings;
use parent 'Catalyst::Controller';
use YAML;

=head1 NAME

DemoApp::RequireLoginController - A Catalyst Controller that redirects to /login if not logged in

=head1 DESCRIPTION

Catalyst Controller base class.


=head1 METHODS

=cut

=head2 auto

this simple auto handler checks if the current user is logged in.
If he/she is, everything is fine. Otherwise a redirect to /login will occur

=cut

sub auto :Private {
    my $self = shift;
    my $c = shift;
 
    if ($c->user_exists) {
        $c->log->debug('RequireLogin -- user exists');
    } else {
        $c->log->debug('RequireLogin -- user DOES NOT EXIST -- must redirect');
        # $c->response->body('<pre>' . Dump($c) . '</pre>');
        # return;

        #
        # what a bad hack to find an ajax request...
        #
        $c->log->debug('ISA ActionChain: ' . $c->action->isa('Catalyst::ActionChain'));
        $c->log->debug('ISA AjaxController: ' . $c->controller->isa('DemoApp::AjaxController'));
        if ($c->action->isa('Catalyst::ActionChain')) {
            $c->log->debug('names: ' . join(', ', map {"$_"} @{$c->action->chain}));
        }
        if (exists($c->{action}->{chain}) && grep {$_->{name} eq 'ajax'} (@{$c->{action}->{chain}})) {
            #
            # looks like an ajax request -- give a short error
            #
            $c->log->debug('looks like a AJAX request...');
            # $c->response->redirect($c->uri_for($c->controller('Login')->action_for('index')));
            $c->response->status(401);
            $c->response->body('You are Unauthorized -- please login');
        } else {
            #
            # regular page call -- simply redirect
            #
            $c->log->debug('wanted URI "' . $c->req->uri->as_string . '" - redirecting to login page');
            $c->flash->{next_page} = $c->req->uri->as_string;
            $c->response->redirect($c->uri_for($c->controller('Login')->action_for('index')));
        }
        return;
    }
    
    return 1;
}

# sub _parse_Redirect_attr {
#     my ($self, $c, $name, $value) = @_;
#     
#     $c->log->debug("Parsing 'Redirect' Attr: v=$value");
#     return;
# }

=head1 AUTHOR

Wolfgang Kinkeldei

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
