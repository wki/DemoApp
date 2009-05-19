package DemoApp::Schema::Result::Colors;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("colors");
__PACKAGE__->add_columns(
  "color_id",
  {
    data_type => "integer",
    default_value => "nextval('colors_color_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "color_name",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 20,
  },
);
__PACKAGE__->set_primary_key("color_id");
__PACKAGE__->add_unique_constraint("colors_pkey", ["color_id"]);
__PACKAGE__->add_unique_constraint("colors_color_name_key", ["color_name"]);
__PACKAGE__->has_many(
  "products",
  "DemoApp::Schema::Result::Products",
  { "foreign.color_id" => "self.color_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-05-19 19:47:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:m/Wb2wYGyFGtTu1ze3pC7A


# You can replace this text with custom content, and it will be preserved on regeneration
1;
