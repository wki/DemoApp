package DemoApp::Form::Simple;
use HTML::FormHandler::Moose;
extends 'HTML::FormHandler';
with 'HTML::FormHandler::Render::Simple';

has_field 'user_name' => (
    is => 'rw',
    required => 1,
);
has_field 'password' => (
    is => 'rw',
);

has_field 'birthday' => (
    is => 'rw',
    type => 'DateTime',
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