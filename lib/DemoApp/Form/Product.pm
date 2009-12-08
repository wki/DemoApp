package DemoApp::Form::Product;
use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
with 'DemoApp::FormLanguage';

use HTML::FormHandler::Types (':all');

has '+item_class'  => ( default =>'Product' );
has '+name'        => ( default => 'product' );
has '+html_prefix' => ( default => 1 );
# has '+submit'      => ( default => sub { { name => 'submit', value => 'Submit' }});

has_field name  => ( 
    type => 'Text', 
    css_class => 'constraint_required', 
    required => 1,
    apply => [Trim],
);

has_field nr    => ( 
    type => 'Text', 
    required => 1,
    apply => [Collapse, Upper],
);

has_field price => ( 
    type => 'Money',
    apply => [PositiveNum],
);

has_field color => ( 
    type => 'Select', 
);

has_field 'submit' => (
    type => 'Submit',
    value => 'Speichern',
);

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
