package DemoApp;

use Moose;
extends 'Catalyst';

use Catalyst::Runtime '5.80';

# Set flags and add plugins for the application
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

# no warnings; # comma's would warn otherwise...
# use Catalyst qw(-Debug
#                 -Log=warn,fatal,error,debug,info
#                 -Stats=1
use Catalyst qw(ConfigLoader
                Static::Simple
                
                I18N
                
                Authentication
                Authorization::Roles
                
                Session
                Session::State::Cookie
                Session::Store::File
               );
our $VERSION = '0.01';

# Configure the application.
#
# Note that settings in demoapp.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

__PACKAGE__->config(
    name => 'DemoApp',
    default_view => 'ByCode',
    default_model => 'DB',
    
    session => {
        cookie_name => 'demoapp_sid',
        storage     => '/tmp/demoapp_session',
    },
    
    authentication => {
        default_realm => 'dbic',
        use_session => 1,
        realms => {
            dbic => {
                credential => {
                    class          => 'Password',
                    password_field => 'password',
                    password_type  => 'clear',
                },
                store => {
                    class          => 'DBIx::Class',
                    user_model     => 'DB::Person',
                    role_relation  => 'DB::PersonRole',
                    role_field     => 'role',
                },
            },
        },
    },
    # needed to make $form->model->create() workable!!!
    'Controller::HTML::FormFu' => {
        model_stash => {
            schema => 'DB',
        },
    },
    
    'TraitFor::Controller::RequireLogin' => {
        bla => 'blubb',
    },
);

sub prepare_path {
    my $c = shift;
    
    $c->next::method(@_);
    
    my $lang = 'de_de';
    $c->languages([$lang]);
    return;
}

# Start the application
__PACKAGE__->setup();


=head1 NAME

DemoApp - Catalyst based application

=head1 SYNOPSIS

    script/demoapp_server.pl

=head1 DESCRIPTION

just a simple demo application

=head1 METHODS

=cut

=head2 uri_for

the overloaded version expands Catalyst's C<uri_for> by allowing

=over

=item *

a component to generate the URI if it can do this

=item *

using path-arguments like C<Controller::action_method> or C<::action_method>

=back

=cut

around uri_for => sub {
    my $orig = shift;
    my $c = shift;
    my $path = shift;
    my @args = @_;
    
    if (blessed($path) && $path->class && $path->class->can('uri_for')) {
        #
        # let the controller handle this for us
        #   believe me, it can do it!
        #
        return $c->component($path->class)->uri_for($c, $path, @args);
    } elsif (!ref($path) && $path && $path =~ m{\A ([A-Z]\w*)? :: (\w+) \z}xms) {
        #
        # looks like 'Controller::action' or '::action'
        #
        return $c->$orig($c->controller( $1 || () )
                           ->action_for( $2 ), 
                         @args);
    }

    return $c->$orig($path, @args);
};

=head1 SEE ALSO

L<DemoApp::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Wolfgang Kinkeldei

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
