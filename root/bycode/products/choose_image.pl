use Data::Dumper; $Data::Dumper::Sortkeys = 1;

block show_list {
    my $dirlist = attr('files');
    return if (!$dirlist || ref($dirlist) ne 'ARRAY' || scalar(@{$dirlist}) < 1);
    
    ul {
        foreach my $entry (@{$dirlist}) {
            li { 
                if (!exists($entry->{children})) {
                    class 'clickable';
                } else {
                    class 'expandable';
                }
                attr value => $entry->{path};
                "$entry->{name}";
            };
            if (exists($entry->{children})) {
                
                show_list(files => $entry->{children});
            };
        }
    };
};


sub RUN {
    div.image_chooser {
        div.head { 
            span.close { 'X' };
            'Bildauswahl' 
        };
        iframe(name => 'image_uploader', style => 'display: none;') {};
        form(action => '/products/ajax/upload', method => 'post', target => 'image_uploader', enctype => 'multipart/form-data') {
            div {
                label { 'Verzeichnis: ' };
                choice{
                    option(value => $_) {$_ || '(oberste Ebene)'}
                        for @{stash->{directories}};
                };
            };
            
            div {
                label { 'Datei: ' };
                input(type => 'file', name => 'file');
            };
            
            div {
                input(type => 'submit', name => 'Hochladen', value => 'Hochladen');
                img._loader(style => {display => 'none'}, src => '/static/images/ajax-loader.gif');
            };
        };
        div.file_list {
            show_list(files => stash->{dirlist});
        };
    };
}
