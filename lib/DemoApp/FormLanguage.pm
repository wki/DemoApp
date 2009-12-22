package DemoApp::FormLanguage;
use Moose::Role;

#
# guess language and apply Locale::Maketext handle if possible
#
sub build_language_handle {
    my $self = shift;
    
    my $lh;
    if ($self->ctx) {
        $lh = HTML::FormHandler::I18N->get_handle(@{$self->ctx->languages});
    }
    
    return $lh || $self->next::method();
}

#
# some magic around field creation
#
around _make_field => sub {
    my ($orig, $self, $field_attr) = @_;
    
    # leave ID as is.
    # $field_attr->{traits} ||= [];
    # push @{$field_attr->{traits}}, 'DemoApp::Form::Field::TraitForIdWithoutDots';
    
    $field_attr->{css_class} .= ' form_line';
    
    $orig->($self, $field_attr);
};

use namespace::autoclean;
1;