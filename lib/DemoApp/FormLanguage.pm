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

use namespace::autoclean;
1;