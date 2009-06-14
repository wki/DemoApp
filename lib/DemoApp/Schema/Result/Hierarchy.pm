package DemoApp::Schema::Result::Hierarchy;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("hierarchy");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('hierarchy_id_seq'::regclass)",
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
  "lft",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "rgt",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("hierarchy_pkey", ["id"]);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-06-14 18:38:32
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:a5eFRAiLxqkmqHdbVpga9A

#
# modify the resulting SELECT statement
#
__PACKAGE__->resultset_attributes({
    where => {
        'parent.lft' => { '<=', \'me.lft' },
        'parent.rgt' => { '>=', \'me.lft' },
    },
    columns => [qw(id name)],
    # join => 'parent',
    from => \'hierarchy me, hierarchy parent',
    '+select' => [ \'count(*)-1' ],
    '+as' => [ 'level' ],
    group_by => ['me.lft', 'me.id', 'me.name'],
    order_by => 'me.lft',
});

1;
