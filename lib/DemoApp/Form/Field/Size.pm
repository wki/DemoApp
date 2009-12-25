package DemoApp::Form::Field::Size;
use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Field::Compound';

has '+is_compound' => (default => 0);

has_field id => ( 
    type => 'Hidden', 
);

has_field product => ( 
    type => 'Hidden', 
);

has_field code => ( 
    type => 'Text', 
    size => 8, 
    widget_wrapper => 'None', # raw fields only
);

has_field name => ( 
    type => 'Text', 
    size => 25, 
    required => 1, 
    widget_wrapper => 'None', # raw fields only
);

no HTML::FormHandler::Moose;
1;
