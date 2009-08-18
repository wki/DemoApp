package DemoApp::View::ByCode;

use strict;
use warnings;
use parent 'Catalyst::View::ByCode';

__PACKAGE__->config(
    # # Change default
    # extension => '.pl',
    # 
    # # Set the location for .pl files
    root_dir => 'root/bycode',
    # 
    # # This is your wrapper template located in the 'root/src'
    # wrapper => 'wrapper.pl',
);

=head1 NAME

DemoApp::View::ByCode - ByCode View for DemoApp

=head1 DESCRIPTION

ByCode View for DemoApp. 

=head1 SEE ALSO

L<DemoApp>

=head1 AUTHOR

Wolfgang Kinkeldei

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
