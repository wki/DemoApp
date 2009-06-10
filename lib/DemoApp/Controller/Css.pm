package DemoApp::Controller::Css;

use strict;
use warnings;
use parent 'Catalyst::Controller::Combine';

# uncomment if desired
# use CSS::Minifier::XS qw(minify);

__PACKAGE__->config(
    #   optional, defaults to static/<<action_namespace>>
    # dir => 'static/css',
    #
    #   optional, defaults to <<action_namespace>>
    # extension => 'css',
    #
    #   specify dependencies (without file extensions)
    depend => {
        navigation => 'default',
        form       => 'default',
        table      => 'default',
        site       => ['form', 'table', 'navigation'],
    },    #
    #   will be guessed from extension
    # mimetype => 'text/css',
    #
    #   if you want another minifier change this
    # minifier => 'minify',
);

#
# defined in base class Catalyst::Controller::Combine
# uncomment and modify if you like
#
# sub default :Path {
#     my $self = shift;
#     my $c = shift;
#     
#     $c->forward('do_combine');
# }

=head1 NAME

DemoApp::Controller::Css - Combine View for DemoApp

=head1 DESCRIPTION

Combine View for DemoApp. 

=head1 SEE ALSO

L<DemoApp>

=head1 AUTHOR

Wolfgang Kinkeldei

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
