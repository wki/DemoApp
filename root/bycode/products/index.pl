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
            with { 
                action => c->uri_for(c->controller->action_for('detail'), $product->id),
                class => '_update_detail'
            } form {
                with {
                    type => 'submit',
                    name => 'Ajax',
                    value => 'Ajax',
                } input;
            };
            div {
                with { href => c->uri_for(c->controller->action_for('show'), $product->id) }
                a { 'detail...' };
            };
            br;
        };
    }
    
    with {id => 'detail' } div { 'detail will follow...'};
    
    pre {
        my $rs = c->model('DB::Product')->search({},{prefetch=>['color','sizes']});
        my $info = $rs->result_source->column_info('name');
        
        my $form = $rs->generate_form_fu({
            indicator => 'Save', 
            auto_fieldset => 0,
            auto_constraint_class => 'constraint_%t',
            attributes => {class => '_enhance'},
        });

        Data::Dumper->Dump([$rs, $info],['rs', 'info']) .
        Data::Dumper->Dump([$form],['form']);
    };

    #div {
    #    pre { Data::Dumper->Dump([c->dispatcher->_dispatch_types],['dispatch_types']); }
    #};
}
