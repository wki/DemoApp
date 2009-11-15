package DemoApp::Controller::Products;

use strict;
use warnings;
use parent qw(Catalyst::Controller::HTML::FormFu
              DemoApp::RequireLoginController 
              DemoApp::AjaxController
              );

use DemoApp::Form::Product;

=head1 NAME

DemoApp::Controller::Products - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub iframe_base :Chained :PathPart('iframe') :CaptureArgs(0) {
}

sub iframe :Chained('iframe_base') :PathPrefix :CaptureArgs(0) {
}

sub thing :Chained('iframe') :Args(0) {
    my $self = shift;
    my $c  = shift;

    # template will be:
    # $c->stash->{template} = 'products/thing.pl';
}

=head2 index

=cut

sub index :Path :Args(0) {
    my $self = shift;
    my $c  = shift;
    
    my $color = $c->model('DB::Color')->by_id(1);

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
    
    $c->stash->{title} .= ' - ' . $c->stash->{product}->name;
}

=head2 edit

a simple editor for a product

=cut

sub edit :Local :Args(1) :FormConfig {
    my $self = shift;
    my $c  = shift;
    my $id = shift;
    
    my $form = $c->stash->{form};
    my $rs = $c->model('DB::Product')->search({},{prefetch => [qw(color sizes)]});
    my $form_structure = $rs->generate_form_fu({
        indicator => 'Save', 
        auto_fieldset => 0,
        auto_constraint_class => 'constraint_%t',
        attributes => {class => '_enhance'},
    });
    # my $form = $self->form($form_structure);
    # $c->stash->{form} = $form;
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
        $form->process();
    }

    $c->stash->{title} .= ' - ' . $c->stash->{product}->name;
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

### FIXME: move me into a dedicated controller
sub choose_image :Chained('ajax') :Args() {
    my ($self, $c, @parts) = @_;
    
    $c->log->debug("choose image, parts = @parts");
    my $dir = $c->path_to(@parts);
    $c->stash->{directories} = [];
    $c->stash->{dirlist} = $self->_content_of($c, $dir);
}

### FIXME: move me into a dedicated controller
sub upload :Chained('ajax') :Args() {
    my ($self, $c, @parts) = @_;
    
    my $upload = $c->request->upload('file');
    $c->log->debug("UPLOAD IMAGE, upload='$upload'");
    $c->log->debug("  file-size=${\$upload->size}, file-name=${\$upload->filename}") if ($upload);
}

# helper: give content of a Path::Class::Dir object
# returns: [ name, name, ... ]
sub _content_of {
    my $self = shift;
    my $c = shift;
    my $dir = shift;
    my $prefix = shift || '';
    
    push @{$c->stash->{directories}}, $prefix;
    
    my @files;
    foreach my $child ($dir->children) {
        my $name = $child->is_dir ? $child->relative($child->parent) : $child->basename;
        push @files, {
            path => "$prefix$name",
            name => $name,
            # children => [], # filled below if needed
        };
        if ($child->is_dir) {
            # a dir object -- must dive inside -- TODO
            my $new_prefix = ($prefix ? "$prefix/" : '') . $files[-1]->{path} . '/';
            $files[-1]->{children} = $self->_content_of($c, $child, $new_prefix);
        } else {
            # a file object -- nothing to do
        }
    }
    
    return \@files;
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

=head2 uritest

just a dummy sample page to test various ways to gerate a uri

=cut

sub uritest :Local {
    my $self = shift;
    my $c = shift;
    
    # nothing inside, just let the template do its work.
}

=head2 formtest

a simple HTML::FormHandler thing

=cut

sub formtest :Local {
    my ($self, $c) = @_;
    
    my $form = DemoApp::Form::Product->new();
    # $form->name('bla');
    $c->stash->{form} = $form;
}

=head1 AUTHOR

Wolfgang Kinkeldei

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
