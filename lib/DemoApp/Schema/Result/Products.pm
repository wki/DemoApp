package DemoApp::Schema::Result::Products;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("products");
__PACKAGE__->add_columns(
  "product_id",
  {
    data_type => "integer",
    default_value => "nextval('products_product_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "product_name",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 40,
  },
  "product_nr",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 10,
  },
  "price",
  {
    data_type => "numeric",
    default_value => undef,
    is_nullable => 1,
    size => "2,9",
  },
  "color_id",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
);
__PACKAGE__->set_primary_key("product_id");
__PACKAGE__->add_unique_constraint("products_pkey", ["product_id"]);
__PACKAGE__->add_unique_constraint("products_product_nr_key", ["product_nr"]);
__PACKAGE__->belongs_to(
  "color_id",
  "DemoApp::Schema::Result::Colors",
  { color_id => "color_id" },
);
__PACKAGE__->has_many(
  "sizes",
  "DemoApp::Schema::Result::Sizes",
  { "foreign.product_id" => "self.product_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-05-19 19:47:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:RpYTPnN6ES0lsyKOG3YPiQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
