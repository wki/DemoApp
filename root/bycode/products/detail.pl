#
# product detail
#
sub RUN {
    div { 'product detail' };
    br;
    
    my $product = stash->{product};
    div {
        div { 'No: '    . $product->nr };
        div { 'Name: '  . $product->name };
        div { 'Price: ' . $product->price };
        br;
    };
}
