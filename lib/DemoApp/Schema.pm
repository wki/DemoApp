package DemoApp::Schema;

use strict;
use warnings;

use base 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces;


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-06-11 20:52:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:qY/IifFyt2sQmuzVI6ekaw

#
# all resultset classes inherit this one
#
__PACKAGE__->load_namespaces(
    default_resultset_class => 'Base::ResultSet',
);

1;
