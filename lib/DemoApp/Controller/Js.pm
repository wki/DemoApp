package DemoApp::Controller::Js;

use strict;
use warnings;
use parent 'Catalyst::Controller::Combine';

# uncomment if desired
use JavaScript::Minifier::XS qw(minify);

__PACKAGE__->config(
    #   optional, defaults to static/<<action_namespace>>
    # dir => 'static/js',
    #
    #   optional, defaults to <<action_namespace>>
    # extension => 'js',
    #
    #   specify dependencies (without file extensions)
    depend => {
        # prototype dependency chain
        scriptaculous         => 'prototype',
        tablekit              => 'prototype',
        builder               => 'scriptaculous',
        effects               => 'scriptaculous',
        dragdrop              => 'effects',
        slider                => 'scriptaculous',
        site                  => ['dragdrop', 'tablekit', 'widgets'],
        
        # jquery dependency chain
        'jquery.metadata'     => 'jquery-1.4',
        'jquery.form-2.36'    => 'jquery-1.4',
        'jquery.validate-1.6' => [qw(jquery.form-2.36 jquery.metadata)],
        default               => [qw(jquery.validate-1.6 jquery-ui-1.7.2)],
    },
    #   will be guessed from extension
    # mimetype => 'application/javascript',
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

DemoApp::Controller::Js - Combine View for DemoApp

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
