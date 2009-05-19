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
            div { 'No: '    . $product->product_nr };
            div { 'Name: '  . $product->product_name };
            div { 'Price: ' . $product->price };
            div {
                foreach my $size ($product->sizes) {
                    li {$size->size_name};
                    # pre { Data::Dumper->Dump([$size],['size']) };
                }
            };
            with { 
                action => c->uri_for(c->controller->action_for('detail'), $product->product_id),
                class => '_update_detail'
            } form {
                with {
                    type => 'submit',
                    name => 'Ajax',
                    value => 'Ajax',
                } input;
            };
            div {
                with { href => c->uri_for(c->controller->action_for('show'), $product->product_id) }
                a { 'detail...' };
            };
            br;
        };
    }
    
    with {id => 'detail' } div { 'detail will follow...'};

    #div {
    #    pre { Data::Dumper->Dump([c->dispatcher->_dispatch_types],['dispatch_types']); }
    #};
}
