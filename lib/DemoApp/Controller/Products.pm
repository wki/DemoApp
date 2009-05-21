package DemoApp::Controller::Products;

use strict;
use warnings;
use parent qw(Catalyst::Controller::HTML::FormFu
              DemoApp::RequireLoginController 
              DemoApp::AjaxController
              );

=head1 NAME

DemoApp::Controller::Products - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my $self = shift;
    my $c  = shift;

    $c->stash->{title} = 'Product List';
    $c->stash->{products} = [ $c->model('DB::Product')
                                ->search(
                                    {
                                    },
                                    {
                                        prefetch => ['sizes', 'color'],
                                        # prefetch => 'sizes',
                                    })
                                ->all() ];
}

=head2 show

show a detail of a product

=cut

sub show :Local :Args(1) {
    my $self = shift;
    my $c  = shift;
    my $id = shift;
    
    $c->stash->{product} = $c->model('DB::Product')->find($id);
    # we must set this to make detail() below work...
    $c->stash->{template} = 'products/detail.pl';
    
    $c->stash->{title} .= ' - ' . $c->stash->{product}->product_name;
}

=head2 edit

a simple editor for a product

=cut

sub edit :Local :Args(1) :FormConfig {
    my $self = shift;
    my $c  = shift;
    my $id = shift;
    
    my $form = $c->stash->{form};
    $c->stash->{product} = $c->model('DB::Product')->find($id);
    
    if ($form->submitted_and_valid) {
        #
        # update DB and re-populate for form with current
        # model's content -- don't forget to clear the form before!
        #
        $c->log->debug('product form submitted and valid');
        
        $form->model->update($c->stash->{product});
        $form->query(HTML::FormFu::FakeQuery->new($form, {}));
        $form->model->default_values($c->stash->{product});
        $form->process();
    } elsif ($form->has_errors) {
        $c->log->debug('product form errors');
        $c->stash->{message} = 'some errors - please retry';
    } else {
        $c->log->debug('product form initial');
        $form->model->default_values($c->stash->{product});
    }

    $c->stash->{title} .= ' - ' . $c->stash->{product}->product_name;
}

=head2 autocompleter

a simple autocompleter callback

=cut

# :PathPart('autocompleter') is default...
sub autocompleter :Chained('ajax') :Args(0) {
    my $self = shift;
    my $c = shift;
        
    # default template: products/autocompleter.pl
}

=head2 detail

The AJAX version of a product detail. Chained with 'ajax' will only display the 
detail without further decoration

=cut

sub detail :Chained('ajax') :Args(1) {
    my $self = shift;
    my $c = shift;
    my @args = @_;
        
    $c->forward('show');
}

=head1 AUTHOR

Wolfgang Kinkeldei

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
