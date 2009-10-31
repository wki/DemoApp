package DemoApp::Controller::FormHandler;

use Moose;
BEGIN { extends 'Catalyst::Controller' }
use DemoApp::Form::Simple;

has form => (isa => 'DemoApp::Form::Simple',
             is => 'ro',
             lazy => 1,
             default => sub { DemoApp::Form::Simple->new }
);

=head1 NAME

DemoApp::Controller::FormHandler - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    # # works but validates:
    # $self->form->process(params => {xuser_name => 'xxx', password => 'abcd'});
    
    my $status = $self->form->process(params => $c->req->parameters);
    $c->log->debug("FORM PROCESS STATUS: $status");
    
    # # works if field->fif_from_value is set
    # $self->form->field('user_name')->value('bla "fasel"');
    
    # works but needs process
    #$self->form->params({user_name => 'blaaa "fasel"'});
    # $self->form->process;
    
    $c->stash->{form} = $self->form;
}


=head1 AUTHOR

Wolfgang Kinkeldei

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
