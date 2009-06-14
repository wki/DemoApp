package DemoApp::Schema::Result::Role;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("role");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 16,
  },
  "name",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 60,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("role_pkey", ["id"]);
__PACKAGE__->has_many(
  "person_role_roles",
  "DemoApp::Schema::Result::PersonRole",
  { "foreign.role" => "self.id" },
);
__PACKAGE__->has_many(
  "person_role_roles",
  "DemoApp::Schema::Result::PersonRole",
  { "foreign.role" => "self.id" },
);
__PACKAGE__->has_many(
  "person_role_roles",
  "DemoApp::Schema::Result::PersonRole",
  { "foreign.role" => "self.id" },
);
__PACKAGE__->has_many(
  "person_role_roles",
  "DemoApp::Schema::Result::PersonRole",
  { "foreign.role" => "self.id" },
);
__PACKAGE__->has_many(
  "person_role_roles",
  "DemoApp::Schema::Result::PersonRole",
  { "foreign.role" => "self.id" },
);
__PACKAGE__->has_many(
  "person_role_roles",
  "DemoApp::Schema::Result::PersonRole",
  { "foreign.role" => "self.id" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-06-14 18:38:32
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:1mVNYQWmxoSOGazz4OTX2A

__PACKAGE__->many_to_many('persons', 'person_roles', 'person');

1;
