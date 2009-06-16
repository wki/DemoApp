package DemoApp::Schema::Result::PersonRole;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("person_role");
__PACKAGE__->add_columns(
  "person",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "role",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 16,
  },
);
__PACKAGE__->set_primary_key("person", "role");
__PACKAGE__->add_unique_constraint("person_role_pkey", ["person", "role"]);
__PACKAGE__->belongs_to(
  "person",
  "DemoApp::Schema::Result::Person",
  { id => "person" },
);
__PACKAGE__->belongs_to("role", "DemoApp::Schema::Result::Role", { id => "role" });


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-06-16 07:57:28
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Tt69j/zn6GxzNfZdnbtMYA


1;
