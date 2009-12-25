package DemoApp::Form::Product;
use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
with 'DemoApp::FormLanguage';

use HTML::FormHandler::Types (':all');

has '+item_class'  => ( default =>'Product' );
has '+name'        => ( default => 'product' );
has '+html_prefix' => ( default => 1 );

has '+widget_form' => ( default => 'Simple' );
has '+widget_name_space' => (default => sub { [qw(DemoApp::Form::Widget)] });

# has 'auto_fieldset' => (default => 0);

# 
# has '+field_traits'=> ( default => sub { ['DemoApp::Form::Field::TraitForIdWithoutDots'] } ); ### TODO!

# sub render_start {}
# sub render {}
# before render => sub {
#     warn "before render in Widget...";
# };

has_field name => ( 
    type => 'Text', 
    size => 40, 
    required => 1, 
    css_class => 'constraint_required',
    apply => [Trim],
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
    # auto_id => 1, ### not needed -- fields in Field::Size.pm
    num_when_empty => 3,
    is_compound => 0,
);

# has_field 'sizes.id' => ( 
#     type => 'Hidden', 
# );
# 
# has_field 'sizes.product' => ( 
#     type => 'Hidden', 
# );
# 
# has_field 'sizes.code' => ( 
#     type => 'Text', 
#     size => 8, 
#     widget_wrapper => 'None', # raw fields only
# );
# 
# has_field 'sizes.name' => ( 
#     type => 'Text', 
#     size => 25, 
#     required => 1, 
#     widget_wrapper => 'None', # raw fields only
# );

has_field 'sizes.contains' => ( 
    type => '+DemoApp::Form::Field::Size', 
    #is_compound => 0, 
    #widget_wrapper => 'None', # raw fields only
);

# testing only
has_field 'created_at' => ( type => '+DemoApp::Form::Field::Date', );

has_field 'updated_at' => (type => 'Date', widget => 'Datepicker');

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
