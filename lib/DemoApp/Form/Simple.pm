package DemoApp::Form::Simple;
use HTML::FormHandler::Moose;
extends 'HTML::FormHandler';
#with 'HTML::FormHandler::Render::Simple';
with 'Catalyst::View::ByCode::FormHandlerRenderer';

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
    # type => 'DateTime',
);

has_field 'birthdate.day' => (
    is => 'rw',
    type => 'MonthDay',
);

has_field 'birthdate.month' => (
    is => 'rw',
    type => 'Month',
);

has_field 'birthdate.year' => (
    is => 'rw',
    type => 'Year',
);

sub validate_user_name {

}
1;