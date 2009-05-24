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
        my $info = c->model('DB::Person')->result_source->column_info('name');
        Data::Dumper->Dump([$info],['info']);
    };

    #div {
    #    pre { Data::Dumper->Dump([c->dispatcher->_dispatch_types],['dispatch_types']); }
    #};
}
