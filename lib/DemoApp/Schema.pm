package DemoApp::Schema;

use strict;
use warnings;

use base 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces;


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-06-09 23:00:49
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:WkmxS2W87sCwNGeHbXe2Fg

#
# all resultset classes inherit this one
#
__PACKAGE__->load_namespaces(
    default_resultset_class => 'Base::ResultSet',
);

1;
