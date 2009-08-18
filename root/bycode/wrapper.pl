#
# our universal wrapper
# building the scaffolding for all pages
#
template {
    doctype 'xhtml';
    html {
        head {
            title { stash->{title} || 'untitled' };
            load Js  => 'site.js';
            load Css => 'site.css';
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
