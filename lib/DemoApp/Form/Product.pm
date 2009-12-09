package DemoApp::Form::Product;
use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
with 'DemoApp::FormLanguage';

use HTML::FormHandler::Types (':all');
use HTML::FormHandler::Field (); ### needed to avoid error when trying to apply +field_traits

has '+item_class'  => ( default =>'Product' );
has '+name'        => ( default => 'product' );
has '+html_prefix' => ( default => 1 );
# has '+field_traits'=> ( default => sub { ['DemoApp::Form::Field::TraitForIdWithoutDots'] } ); ### TODO!

has_field name => ( 
    type => 'Text', 
    size => 40, 
    required => 1, 
    css_class => 'constraint_required',
    apply => [Trim],
    # works but must be repeated:
    # traits => ['DemoApp::Form::Field::TraitForIdWithoutDots'],
);

has_field nr => ( 
    type => 'Text', 
    size => 10, 
    required => 1, 
    css_class => 'constraint_required',
    apply => [Trim],
);

has_field price => ( 
    type => 'Money', 
    apply => [PositiveNum],
);

has_field color => ( 
    type => 'Select', 
);

has_field sizes => ( 
    type => 'Repeatable', 
    # auto_id => 1,
    is_compound => 0,
    # contains => 'sizes.size',
);

has_field 'sizes.contains' => ( 
    type => '+DemoApp::Form::Field::Size', 
    is_compound => 0, 
    widget_wrapper => 'None', # raw fields only
);

# testing only
has_field 'created_at' => ( type => '+DemoApp::Form::Field::Date', );

has_field 'submit' => ( type => 'Submit', value => 'Save', );

### automatically generated from DB (!)
# sub options_color {
#    my $self = shift;
#    return unless $self->schema;
# 
#    my $licenses = $self->schema->resultset('Color')->search({}, {order_by => 'id'});
#    my @selections = ( {value => 'undef', label => '- choose -'} );
#    while (my $license = $licenses->next) {
#       push @selections, { value => $license->id, label => $license->name, };
#    }
#    
#    return @selections; 
# }


no HTML::FormHandler::Moose;
1;
