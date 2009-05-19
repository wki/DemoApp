package DemoApp::Schema::Result::PersonsRoles;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("persons_roles");
__PACKAGE__->add_columns(
  "person_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "role_id",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 16,
  },
);
__PACKAGE__->set_primary_key("person_id", "role_id");
__PACKAGE__->add_unique_constraint("persons_roles_pkey", ["person_id", "role_id"]);
__PACKAGE__->belongs_to(
  "role_id",
  "DemoApp::Schema::Result::Roles",
  { role_id => "role_id" },
);
__PACKAGE__->belongs_to(
  "person_id",
  "DemoApp::Schema::Result::Persons",
  { person_id => "person_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-05-19 19:47:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:JoZ96KmzE1jfrPi6X0ALUg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
