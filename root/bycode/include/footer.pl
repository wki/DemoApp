#
# footer component with
#  - copyright notice
#  - catalyst logo
#
template {
    div {
        a(href => 'http://www.catalystframework.org/',
          target => '_blank') {
            img(style => {float => 'right'}, 
                src => '/static/images/btn_88x31_powered.png', 
                width => 88, 
                height => 31);
        };
        div.copyright { "Copyright \x{00a9} 2009 WK"; };
    }
};
