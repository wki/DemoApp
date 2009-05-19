package DemoApp::Schema::Result::Persons;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("persons");
__PACKAGE__->add_columns(
  "person_id",
  {
    data_type => "integer",
    default_value => "nextval('persons_person_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "person_name",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 40,
  },
  "person_login",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 20,
  },
  "person_password",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 20,
  },
  "person_email",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 40,
  },
  "person_active",
  {
    data_type => "boolean",
    default_value => "true",
    is_nullable => 0,
    size => 1,
  },
);
__PACKAGE__->set_primary_key("person_id");
__PACKAGE__->add_unique_constraint("persons_person_login_key", ["person_login"]);
__PACKAGE__->add_unique_constraint("persons_pkey", ["person_id"]);
__PACKAGE__->has_many(
  "persons_roles",
  "DemoApp::Schema::Result::PersonsRoles",
  { "foreign.person_id" => "self.person_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-05-19 19:47:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:fwkwKeMGlLNbQBfs3Pj/QQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
