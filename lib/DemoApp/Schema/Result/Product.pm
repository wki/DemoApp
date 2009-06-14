package DemoApp::Schema::Result::Product;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("product");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('product_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "name",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 40,
  },
  "nr",
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
  "color",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("product_pkey", ["id"]);
__PACKAGE__->add_unique_constraint("product_nr_key", ["nr"]);
__PACKAGE__->belongs_to("color", "DemoApp::Schema::Result::Color", { id => "color" });
__PACKAGE__->belongs_to("color", "DemoApp::Schema::Result::Color", { id => "color" });
__PACKAGE__->belongs_to("color", "DemoApp::Schema::Result::Color", { id => "color" });
__PACKAGE__->belongs_to("color", "DemoApp::Schema::Result::Color", { id => "color" });
__PACKAGE__->belongs_to("color", "DemoApp::Schema::Result::Color", { id => "color" });
__PACKAGE__->belongs_to("color", "DemoApp::Schema::Result::Color", { id => "color" });
__PACKAGE__->has_many(
  "size_products",
  "DemoApp::Schema::Result::Size",
  { "foreign.product" => "self.id" },
);
__PACKAGE__->has_many(
  "size_products",
  "DemoApp::Schema::Result::Size",
  { "foreign.product" => "self.id" },
);
__PACKAGE__->has_many(
  "size_products",
  "DemoApp::Schema::Result::Size",
  { "foreign.product" => "self.id" },
);
__PACKAGE__->has_many(
  "size_products",
  "DemoApp::Schema::Result::Size",
  { "foreign.product" => "self.id" },
);
__PACKAGE__->has_many(
  "size_products",
  "DemoApp::Schema::Result::Size",
  { "foreign.product" => "self.id" },
);
__PACKAGE__->has_many(
  "size_products",
  "DemoApp::Schema::Result::Size",
  { "foreign.product" => "self.id" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-06-14 18:38:32
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:uYJYtZjFx+U2Br4ehqr7mA

#
# patch above 'belongs_to' relation!
#
__PACKAGE__->belongs_to("color", "DemoApp::Schema::Result::Color", 
                        { id => "color" }, 
                        { join_type => 'left' });

#
# add some things for easier HTML-FormFu form generation
#
__PACKAGE__->form_fu_extra(name => {
    constraints => 'Required',
    filters     => 'TrimEdges',
});

__PACKAGE__->form_fu_extra(nr => {
    constraints => [
        'Required',
        {
            type    => 'Regex',
            regex   => '^[A-Z0-9]{4,8}$',
            message => 'only A-Z, 0-9 allowed',
        },
    ],
    filters     => 'TrimEdges',
});

__PACKAGE__->form_fu_extra(price => {
    constraints => [qw(Required Number)],
    filters     => 'TrimEdges',
});

1;
