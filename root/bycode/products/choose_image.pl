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
                attr value => $entry->{path};
                $entry->{name}; 
            };
            if (exists($entry->{children})) {
                show_list(files => $entry->{children});
            };
        }
    };
};


sub RUN {
    div(style => {position => 'absolute', top => '0px', left => '0px', width => '300px', height => '260px', 'overflow-y' => 'scroll', 'background-color' => '#ffffff', border => '1px solid black', padding => '7px', 'z-index' => 1000}) {
        div { 
            span.close(style => {float => 'right'}) { 'X' };
            'choose an image!' 
        };
        iframe(name => 'image_uploader', style => 'display: none;') {};
        form(action => '/products/ajax/upload', target => 'image_uploader', enctype => 'multipart/form-data') {
            label { 'directory: ' };
            choice{
                option(value => $_) {$_}
                    for @{stash->{directories}};
            };
            br;
            
            label { 'file: ' };
            input(type => 'file', name => 'file');
            br;
            
            label { ' ' };
            input(type => 'submit', name => 'Go', value => 'Go');
        };
        div {
            show_list(files => stash->{dirlist});
        };
    };
}
