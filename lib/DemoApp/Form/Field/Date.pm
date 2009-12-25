package DemoApp::Form::Field::Date;
use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Field::Compound';

has '+is_compound' => (default => 0); # no <fieldset> around

has_field day => (
    is => 'rw',
    type => 'MonthDay',
    widget_wrapper => 'None', # raw fields only
);

has_field month => (
    is => 'rw',
    type => 'Month',
    widget_wrapper => 'None', # raw fields only
);

has_field year => (
    is => 'rw',
    type => 'Year',
    widget_wrapper => 'None', # raw fields only
);

no HTML::FormHandler::Moose;
1;
