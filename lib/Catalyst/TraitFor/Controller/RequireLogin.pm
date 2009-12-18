package Catalyst::TraitFor::Controller::RequireLogin;
use MooseX::MethodAttributes::Role;

#
# just an experimental trait to see if things can get simplified
# also some config settings are possible.
# TODO: think about config handling, maybe merging with component config.
#


our $VERSION = '0.01';

# will be overwritten by controller.
sub auto :Private {
    return 1;
}

around auto => sub {
    my ($orig, $controller, $c) = @_;
    
    $c->log->debug('in around AUTO ...');
    my $config = $c->config->{'TraitFor::Controller::RequireLogin'} || {};
    $c->log->debug("bla = $config->{bla}");
    
    return $orig->($controller, $c);
};


1;
