package DemoApp::Form::Simple;
use HTML::FormHandler::Moose;
extends 'HTML::FormHandler'; # OR: 'HTML::FormHandler::Model::DBIC';
# with 'Catalyst::View::ByCode::FormHandlerRenderer';
# with 'Catalyst::View::ByCode::FormHandler';

has '+widget_name_space' => (
    default => sub { ['DemoApp::Form::Widget'] },
);

has_field 'user_name' => (
    is => 'rw',
    fif_from_value => 1,
    required => 1,
);
has_field 'password' => (
    is => 'rw',
);

has_field 'birthdate' => (
    is => 'rw',
    type => 'Compound',
    is_compound => 0,      # don't show a fieldset around
    label => 'Birthday',
);

has_field 'birthdate.day' => (
    is => 'rw',
    type => 'MonthDay',
    widget_wrapper => 'None', # raw fields only
);

has_field 'birthdate.month' => (
    is => 'rw',
    type => 'Month',
    widget_wrapper => 'None', # raw fields only
);

has_field 'birthdate.year' => (
    is => 'rw',
    type => 'Year',
    widget_wrapper => 'None', # raw fields only
);

has_field 'submit' => (
    type => 'Submit',
    value => 'Submit',
    fif_from_value => 1,
);

sub validate_user_name {
    my ($self, $field) = @_;
    
    $field->add_error('must be filled with letters.')
        if ($field->value !~ m{\w}xms)
}

1;