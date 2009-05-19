package DemoApp::AjaxController;

use strict;
use warnings;
use parent 'Catalyst::Controller';

=head1 NAME

DemoApp::AjaxController - A Catalyst Controller that acts as a base for others

=head1 DESCRIPTION

Catalyst Controller base class.

When inherited, defines C<begin> and C<end> methods as a convenience.

Also, a simple chain is predefined, consuming the inheriting Component's path_prefix plus 'ajax' as a URI path.

Succeeding ajax-actions could easily get chained to 'ajax' and only need to define the ajax actions themselves.

    # matches /<<path_prefix>>/ajax/something
    sub something :Chained('ajax') {
        # ... your code
    }

=head1 METHODS

=cut

=head2 begin

a conveniently defined C<begin> that sets some stash-variables

=over

=item is_ajax_request

is set to a boolean false value (0) to indicate that the current request is a
standard request requiring the whole framework

=back

=cut

sub begin :Private {
    my $self = shift;
    my $c = shift;
    
    $c->stash->{is_ajax_request} = 0;
}

=head2 end

A default C<end> that forwares to 'RenderView'

=cut

sub end :ActionClass('RenderView') {}

=head2 base

a helper subroutine that acts as a base for chaining and captures the subclassing component's path_prefix part

=cut

# :PathPrefix === :PathPart('products')
# :Chained === :Chained('/')
sub base :PathPrefix :Chained :CaptureArgs(0) {}

=head2 ajax

a part of a chain consuming 'ajax'. This one is chained immediately after 'base' which grabs the path_prefix.

Here, the wrapper is switched off to ensure proper operation

=cut

# :PathPart('ajax') is default...
# w/o :CaptureArgs(0) -- /products/ajax would be public
sub ajax :Chained('base') :CaptureArgs(0) {
    my $self = shift;
    my $c = shift;
    
    $c->stash->{wrapper} = undef; # don't wrap
    $c->stash->{is_ajax_request} = 1;
    # $c->stash->{template} = 'ajax.pl';
}

=head1 AUTHOR

Wolfgang Kinkeldei

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
