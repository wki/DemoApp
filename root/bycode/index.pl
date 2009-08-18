block show_info {
    my $id = attr('id') || '(undef)';
    #print OUT 'tag: ' . $Catalyst::View::ByCode::Renderer::document->current_tag->tag;
    #br;
    #print OUT 'attrs: ' . join(',', $Catalyst::View::ByCode::Renderer::document->current_tag->attrs);
    div info {
        print OUT 'info block - ';
        block_content;
        print OUT " - attr id = $id --- " . (attr('id') || 'N/A');
        br;
    };
};


template {
    h1 { 'home page' };
    show_info test.x123(abc => 42) { 'bla' };
};
