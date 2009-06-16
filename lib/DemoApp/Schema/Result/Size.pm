package DemoApp::Schema::Result::Size;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("size");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('size_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "product",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "name",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 40,
  },
  "code",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 10,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("size_pkey", ["id"]);
__PACKAGE__->belongs_to(
  "product",
  "DemoApp::Schema::Result::Product",
  { id => "product" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-06-16 07:57:28
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:wIsqniWOiJZv5KkxBhkObQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
