package DemoApp::Schema::Result::Person;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("person");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('person_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "name",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 40,
  },
  "login",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 20,
  },
  "password",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 20,
  },
  "email",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 40,
  },
  "active",
  {
    data_type => "boolean",
    default_value => "true",
    is_nullable => 0,
    size => 1,
  },
  "valid_from",
  { data_type => "date", default_value => undef, is_nullable => 1, size => 4 },
  "valid_until",
  { data_type => "date", default_value => undef, is_nullable => 1, size => 4 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("person_login_key", ["login"]);
__PACKAGE__->add_unique_constraint("person_pkey", ["id"]);
__PACKAGE__->has_many(
  "person_roles",
  "DemoApp::Schema::Result::PersonRole",
  { "foreign.person" => "self.id" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-06-16 07:57:28
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:edFB2jCRKocJQtKJ5paJFQ

__PACKAGE__->many_to_many('roles', 'person_roles', 'role');

1;
