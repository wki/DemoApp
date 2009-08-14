block show_info {
    my $id = attr('class');
    div info {
        print OUT 'info block - ';
        block_content;
        print OUT " - attr id = $id";
    };
};


template {
    h1 { 'home page' };
    show_info.test { attr uu => 42; 'bla' };
};
