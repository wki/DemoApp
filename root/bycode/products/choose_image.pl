use Data::Dumper; $Data::Dumper::Sortkeys = 1;

block show_list {
    my $dirlist = attr('files');
    return if (!$dirlist || ref($dirlist) ne 'ARRAY' || scalar(@{$dirlist}) < 1);
    
    ul {
        foreach my $entry (@{$dirlist}) {
            li { 
                if (!exists($entry->{children})) {
                    class 'clickable';
                }
                $entry->{name}; 
            };
            if (exists($entry->{children})) {
                show_list(files => $entry->{children});
            };
        }
    };
};


sub RUN {
    div(style => {position => 'absolute', top => '0px', left => '0px', width => '200px', height => '200px', 'overflow-y' => 'scroll', 'background-color' => '#ffffff', border => '1px solid black', padding => '7px', 'z-index' => 1000}) {
        div { 'choose an image!' };
        div {
            show_list(files => stash->{dirlist});
        };
    };
}
