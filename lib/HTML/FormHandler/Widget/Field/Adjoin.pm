package HTML::FormHandler::Widget::Field::Adjoin;

use Moose::Role;

sub render {
    my ( $self, $result ) = @_;

    #warn "ADJOIN - RENDER";
    $result ||= $self->result;
    my $output = '';
    foreach my $subfield ( $self->sorted_fields ) {
        my $subresult = $result->field( $subfield->name );
        next unless $subresult;
        $output .= $subfield->render($subresult);
    }
    return $self->wrap_field( $result, $output );
}

use namespace::autoclean;

1;
