package DemoApp::Form::Field::TraitForIdWithoutDots;
use Moose::Role;
use HTML::FormHandler::Field;

#
# this does not really make sense. Lots of forms have ID and NAME the same !!!
#
sub build_id {
    my $self = shift;
    my $id = $self->html_name;
    
    $id =~ s{\.}{_}xmsg;
    
    return $id;
}

warn "running TraitForIdWithoutDots";

1;
