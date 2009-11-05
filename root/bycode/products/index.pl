use Data::Dumper;

#
# product listing
#
sub RUN {
    c->session->{page}++;

    div { "($$) product list - page: " . c->session->{page} };
    br;

    foreach my $product (@{stash->{products}}) {
        div {
            div { 'No: '    . $product->nr };
            div { 'Name: '  . $product->name };
            div { 'Price: ' . $product->price };
            div { 'Color: ' . $product->color->name } if ($product->color);
            div {
                foreach my $size ($product->sizes) {
                    li {$size->name};
                }
            };
            form (action => c->uri_for(c->controller->action_for('detail'), $product->id),
                  class => '_update_detail') {
                input (type => 'submit',
                       name => 'Ajax',
                       value => 'Ajax') ;
            };
            div {
                a (href => c->uri_for(c->controller->action_for('show'), $product->id)) { 'detail...' };
            };
            br;
        };
    }
    
    div detail { 'detail will follow...'};
    
    pre {
        my $rs = c->model('DB::Product')->search({},{prefetch=>['color','sizes']});
        # my $rs = c->model('DB::Person')->search({},{join => {person_roles => 'role'}});
        #my $info = $rs->result_source->column_info('name');
        
        my $form = $rs->generate_form_fu({
            indicator             => 'Save', 
            auto_fieldset         => 0,
            auto_constraint_class => 'constraint_%t',
            attributes            => {class => '_enhance'},
            append                => {type => 'Blank'},
        });

        Data::Dumper->Dump([$rs],['rs']) .
        Data::Dumper->Dump([$form],['form']);
    };
}
