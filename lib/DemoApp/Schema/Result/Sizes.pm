package DemoApp::Schema::Result::Sizes;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("sizes");
__PACKAGE__->add_columns(
  "size_id",
  {
    data_type => "integer",
    default_value => "nextval('sizes_size_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "product_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "size_name",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 40,
  },
  "size_code",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 10,
  },
);
__PACKAGE__->set_primary_key("size_id");
__PACKAGE__->add_unique_constraint("sizes_pkey", ["size_id"]);
__PACKAGE__->belongs_to(
  "product_id",
  "DemoApp::Schema::Result::Products",
  { product_id => "product_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-05-19 19:47:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:PKNB6fuw35L9aLqiMDd5PA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
