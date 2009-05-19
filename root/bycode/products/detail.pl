#
# product detail
#
sub RUN {
    div { 'product detail' };
    br;
    
    my $product = stash->{product};
    div {
        div { 'No: '    . $product->product_nr };
        div { 'Name: '  . $product->product_name };
        div { 'Price: ' . $product->price };
        br;
    };
}
