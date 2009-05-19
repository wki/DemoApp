package DemoApp::Schema::Result::Roles;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("roles");
__PACKAGE__->add_columns(
  "role_id",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 16,
  },
  "role_name",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 60,
  },
);
__PACKAGE__->set_primary_key("role_id");
__PACKAGE__->add_unique_constraint("roles_pkey", ["role_id"]);
__PACKAGE__->has_many(
  "persons_roles",
  "DemoApp::Schema::Result::PersonsRoles",
  { "foreign.role_id" => "self.role_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-05-19 19:47:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:2mSLw+RxLHLWQnvfQXJYqw


# You can replace this text with custom content, and it will be preserved on regeneration
1;
