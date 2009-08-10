package HTML::FormHandler::Field::Adjoin;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Field::Compound';

has '+widget'           => ( default => 'adjoin' );

__PACKAGE__->meta->make_immutable;
no Moose;
1;
