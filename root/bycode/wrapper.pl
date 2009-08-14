#
# our universal wrapper
# building the scaffolding for all pages
#
template {
    doctype 'xhtml';
    html {
        head {
            title { stash->{title} || 'untitled' };
            # load Js  => 'site.js';
            # load Css => 'site.css';
            # load Js => 'dragdrop'; # will append to load Js above...
        };
        body {
            div header { yield 'header'; };
            div main.clearfix {
                div leftnav { yield 'leftnav'; };
                div content { yield; };
            };
            div footer { yield 'footer'; };
        };
    };
};
