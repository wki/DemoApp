package DemoApp::Form::Product;
use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';
with 'HTML::FormHandler::Render::Simple';

has '+item_class'  => ( default =>'Products' );
has '+name'        => ( default => 'book' );
has '+html_prefix' => ( default => 1 );
has '+submit'      => ( default => sub { { name => 'submit', value => 'Submit' }});

has_field name  => ( type => 'Text' );
has_field nr    => ( type => 'Text' );
has_field price => ( type => 'Money' );
# has_field color => ( type => 'Select', )

no HTML::FormHandler::Moose;
1;
