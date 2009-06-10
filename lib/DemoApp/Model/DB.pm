package DemoApp::Model::DB;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'DemoApp::Schema',
    connect_info => [
        'dbi:Pg:dbname=demoapp',
        'postgres',
        '',
    ],
);

DBIx::Class->load_components('FormFuBuilder');

=head1 NAME

DemoApp::Model::DB - Catalyst DBIC Schema Model
=head1 SYNOPSIS

See L<DemoApp>

=head1 DESCRIPTION

L<Catalyst::Model::DBIC::Schema> Model using schema L<DemoApp::Schema>

=head1 AUTHOR

Wolfgang Kinkeldei

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
