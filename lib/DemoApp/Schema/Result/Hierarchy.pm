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
  "root",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
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


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-06-11 20:52:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:f+CZNpY4BhnQyI3bvAXEeQ

# fake a has-many relation
#   SELECT n.name,
#          COUNT(*)-1 AS level
#     FROM tree AS n,
#          tree AS p
#    WHERE n.lft BETWEEN p.lft AND p.rgt
# GROUP BY n.lft
# ORDER BY n.lft;

# stolen from github.com/melo/dbix--class--tree--nestedset
# $class->has_many(
#     $args->{children_rel} => $class,
#     \%join_cond,
#     { where    => \"me.$left > parent.$left AND me.$right < parent.$right",
#       order_by =>  "me.$left",
#       from     =>  "$table me, $table parent" },
# );


__PACKAGE__->has_one(
  "parent",
  "DemoApp::Schema::Result::Hierarchy",
  { 'foreign.root' => 'self.root' }
);

1;
