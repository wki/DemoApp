package DBIx::Class::FormFuBuilder;
use strict;
use warnings;

# use base 'DBIx::Class';

=head1 NAME

DBIx::Class::FormFuBuilder

=head1 SYNOPSIS

    # inside your Schema class:
    package Your::Schema;
    ...
    DBIx::Class->load_components('FormFuBuilder');
    
    
    # inside your result classes do this:
    package DemoApp::Schema::Result::Product;
    ...
    __PACKAGE__->form_fu_extra(column_name => {...});
    
    
    # at any place you need a form
    my $form = $result_set->generate_form_fu(...)

more examples to come!

=head1 METHODS

=cut

=head2 form_fu_extras

specify some extra(s) that get into the {extra}->{form_fu} hash of a column

meaningful things could be:

=over 

=item title

=item label

=item constraints

=item filters

=back

=cut

sub form_fu_extra {
    die 'not yet done';
}

=head2 generate_form_fu

generate a form from a resultset including all joined tables

=cut

sub generate_form_fu {
    my $rs = shift;
    my $args = shift || {};
    
    die 'only usable on classes derieved from "DBIx::Class::ResultSet"'
        unless $rs->isa('DBIx::Class::ResultSet');
    
    my $result_source = $rs->result_source;
    my $cols = join(', ', $result_source->columns);
    warn "calling generate_form_fu with $rs / class=$result_source, cols=$cols";
    
    #
    # build form scaffolding
    #
    my %form = (
        attributes  => {},
        elements    => [],
        constraints => [],
        
        %{$args}
    );
    
    #
    # add elements
    #
    $rs->_add_elements($result_source => $form{elements},
                       $rs->{_attrs}->{alias} || 'me',
                       @{$rs->{_attrs}->{select}} );

    if ($args->{indicator}) {
        push @{$form{elements}}, {
            type => 'Submit',
            name => $args->{indicator},
            value => $args->{indicator},
            label => ' ',
        };
    }
    
    #
    # done :-)
    #
    return \%form;
}

#
# add all fields from a list starting with alias
#
sub _add_elements {
    my $rs = shift;
    my $result_source = shift;
    my $elements = shift;
    my $alias = shift;
    my @columns = @_;
    
    #
    # add hidden ID for primary columns
    #
    my %is_primary = ();
    foreach my $primary_col ($result_source->primary_columns) {
        $is_primary{$primary_col} = 1;
        push @{$elements}, {
            type => 'Hidden',
            name => $primary_col,
        };
    }
    
    #
    # determine relationships
    #
    my @relationships = $result_source->relationships;
    my %has_one;  # my column => foreign result source class
    my %has_many; # relationship_name => 1
    foreach my $rel (@relationships) {
        my $rel_info = $result_source->relationship_info($rel);
        my @rel_fields = map {my $x = $_; $x =~ s{\A self [.]}{}xms; $x;}
                         grep {m{\A self [.]}xms}
                         (%{$rel_info->{cond}});
        if (scalar(@rel_fields) != 1) {
            #
            # Houston - we have a problem. We only can handle 1 field...
            #
        } elsif ($rel_info->{attrs}->{is_foreign_key_constraint}) {
            #
            # looks like a has_one relationship
            #
            $has_one{$rel_fields[0]} = $rel_info;
        } elsif ($is_primary{$rel_fields[0]}) {
            #
            # Looks like a has_many relationship
            #
            $has_many{$rel} = $rel_info;
        } else {
            #
            # TODO: find a condition for many_to_many
            #
        }
    }
    
    #
    # loop over fields
    #
    foreach my $column_with_alias (@columns) {
        # filter out columns we do not want...
        next if ($column_with_alias !~ m{\A $alias [.]}xms);
        
        my $column = $column_with_alias;
        $column =~ s{\A $alias [.]}{}xms;
        next if ($is_primary{$column});
        
        # get the column's info
        my $info = $result_source->column_info($column);
        
        # OK we got a field left to generate
        my %field = (
            name        => $column,
            label       => ucfirst($column),
            type        => 'Text',
            constraints => [],
            filters     => [],
            
            # %{$info->{extras}->{formfu} || {}},
        );
        if (exists($info->{extras}->{formfu})) {
            # poor man's deep copy...
            foreach my $key (%{$info->{extras}->{formfu}}) {
                my $value = $info->{extras}->{formfu}->{$key};
                if (!ref($value)) {
                    $field{$key} = $value;
                } elsif (ref($value) eq 'HASH') {
                    $field{$key} = { %{$value} };
                } elsif (ref($value) eq 'ARRAY') {
                    $field{$key} = [ @{$value} ];
                }
            }
        }
        
        if (exists($has_one{$column})) {
            #
            # has-one relation
            #
            $field{type} = 'Select';
            if ($info->{is_nullable}) {
                $field{empty_first} = 1;
                $field{empty_first_label} = '- none -';
            }
            $field{model_config} = {
                resultset    => $has_one{$column}->{source},
                label_column => 'name', ### FIXME: wrong for other cases!
                attributes   => {
                    order_by => 'name', ### FIXME
                    ### TODO: fill me
                },
            };
            #delete $field{constraints};
            #delete $field{filters};
        } else {
            #
            # simple field
            #
            if (!$info->{is_nullable}) {
                push @{$field{constraints}}, {type => 'Required'};
            }
            if ($info->{data_type} eq 'numeric') {
                push @{$field{constraints}}, {type => 'Number'};
            }
        }
        
        push @{$elements}, \%field;
    }

    #
    # finally add all has_many relationships
    #
    foreach my $from (@{$rs->{_attrs}->{from}}) {
        next if (ref($from) ne 'ARRAY');
        my ($rel_name) = grep {exists($has_many{$_})} keys(%{$from->[0]});
        next if (!$rel_name);
    
        # we found a has-many relation we would join in a select
        my %repeatable = (
            type         => 'Repeatable',
            nested_name  => $rel_name,
            counter_name => "${rel_name}_count",
            model_config => {
                empty_rows   => 1,
                new_rows_max => 10,
            },
            elements => [],
        );
        
        my @repeat_columns;
        foreach my $column (@columns) {
            next if ($column !~ m{\A $rel_name [.]}xms);
            my $short_col = $column;
            $short_col =~ s{\A \w+ [.]}{}xms;
            next if (grep {m{\A foreign [.] $short_col}xms} %{$has_many{$rel_name}->{cond}});
            push @repeat_columns, $column;
        }
        $rs->_add_elements($has_many{$rel_name}->{source} => $repeatable{elements},
                           $rel_name, @repeat_columns);
        
        push @{$elements}, \%repeatable;
        
        push @{$elements}, {
            type => 'Hidden',
            name => "${rel_name}_count",
        };
    }

}

=head1 AUTHOR

Wolfgang Kinkeldei, E<lt>wolfgang@kinkeldei.deE<gt>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

