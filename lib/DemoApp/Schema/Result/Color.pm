package DemoApp::Schema::Result::Color;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("color");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('color_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "name",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 20,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("color_pkey", ["id"]);
__PACKAGE__->add_unique_constraint("color_name_key", ["name"]);
__PACKAGE__->has_many(
  "products",
  "DemoApp::Schema::Result::Product",
  { "foreign.color" => "self.id" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-06-10 11:52:39
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:7FTuZjjblKIRxt6vbdicKw

__PACKAGE__->form_fu_extra(name => {
    constraints => 'Required',
    filters     => 'TrimEdges',
});

1;
