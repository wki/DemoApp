package DemoApp::Schema;

use strict;
use warnings;

use base 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces;


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-06-14 18:38:32
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Vzn5kVV4LloZRi/ADkusTg

#
# all resultset classes inherit this one
#
__PACKAGE__->load_namespaces(
    default_resultset_class => 'Base::ResultSet',
);

1;
