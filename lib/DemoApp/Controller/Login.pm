package DemoApp::Controller::Login;

use strict;
use warnings;
use parent qw(Catalyst::Controller::HTML::FormFu);
use YAML;

=head1 NAME

DemoApp::Controller::Login - Catalyst Controller

=head1 SYNOPSIS

check roles like:

    if ($c->user_exists && $c->check_user_roles('edit')) {
        # role 'edit' granted, go on...
    }

use C<<$c->flash->{next_page}>> to direct the succesful login onto a uri you like.

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 auto :Private

before rendering the login page, set the title and delete the header from the yi
eld-list

=cut

sub auto :Private {
    my $self = shift;
    my $c = shift;

    delete $c->stash->{yield}->{header};
    
    $c->keep_flash('next_page');
    
    $c->stash->{title} = 'Login Page';
}

=head2 index

the actual login page.

Displays a login form, receives login input and performs the login.
When successful, redirects to '/'

=cut

sub index :Path :Args(0) :FormConfig { # FormConfig('login/index.yml') {
    my $self = shift;
    my $c = shift;
    
    my $form = $c->stash->{form};
    
    if ($form->submitted_and_valid) {
        $c->log->debug('login form submitted and valid');
        my $username = $form->params->{username} || '';
        my $password = $form->params->{password} || '';
        
        if ($c->authenticate({ person_login    => $username,
                               person_password => $password  } )) {
            # successful login
            $c->persist_user();
            $c->res->redirect($c->flash->{next_page} || '/');
        } else {
            $c->log->debug('login failed');
            $c->stash->{message} = 'login failed - please try again';
        }
    } elsif ($form->has_errors) {
        $c->log->debug('login form errors');
        $c->stash->{message} = 'some errors - please retry';
    } else {
        $c->log->debug('login form initial');
    }
}

=head2 forgot_password

=cut

sub forgot_password :Local :FormConfig { # FormConfig('login/forgot_password.yml') {
    my $self = shift;
    my $c = shift;
    
    my $form = $c->stash->{form};
    
    if ($form->submitted_and_valid) {
        $c->log->debug('forgot form submitted and valid');
        $c->stash->{message} = 'email will be sent to you';
        ### TODO: auto-login and continue
    } elsif ($form->has_errors) {
        $c->log->debug('forgot form errors');
        $c->stash->{message} = 'some errors - please retry';
    } else {
        $c->log->debug('forgot form initial');
    }
    
    $c->stash->{title} = 'Forgot Password';
}

=head2 register

=cut

sub register :Local :FormConfig { # FormConfig('login/register.yml') {
    my $self = shift;
    my $c = shift;

    my $form = $c->stash->{form};
    
    if ($form->submitted_and_valid) {
        $c->log->debug('register form submitted and valid');
        $c->stash->{message} = 'registration is valid';
        
        #
        # add to DB
        #
        $form->model->update( $c->model('DB::Persons')->new_result({}) );
    } elsif ($form->has_errors) {
        $c->log->debug('register form errors');
        $c->stash->{message} = 'some errors - please retry';
    } else {
        $c->log->debug('register form initial');
    }

    $c->stash->{title} = 'Register';
}

=head2 logout

logout the current user and display a logout message

=cut

sub logout :Global("/logout") {
    my $self = shift;
    my $c = shift;
    
    $c->logout();

    $c->stash->{title} = 'Logout';
}

=head2 email_check

registration form callback

check if email is unique

=cut

sub email_check :Private {
    my $value = shift;
    my $params = shift;

    my $result = cat_app->model('DB::Persons')->search({person_email => $value});
    
    return $result->next ? 0 : 1;
}

=head2 login_check

registration form callback

check if login is unique

=cut

sub login_check :Private {
    my $value = shift;
    my $params = shift;

    my $result = cat_app->model('DB::Persons')->search({person_login => $value});
    
    return $result->next ? 0 : 1;
}

=head2 double_check

registration form callback

check if password is correctoy repeated at registration

=cut

sub double_check :Private {
    my $value = shift;
    my $params = shift;
        
    return $params->{person_password} eq $value;
}

=head1 AUTHOR

Wolfgang Kinkeldei

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
