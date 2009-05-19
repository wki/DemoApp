#
# footer component with
#  - copyright notice
#  - catalyst logo
#
div {
    with {href => 'http://www.catalystframework.org/',
          target => '_blank'
    } a {
        with {style => {float => 'right'}, 
              src => '/static/images/btn_88x31_powered.png', 
              width => 88, 
              height => 31
        } img;
    };
    with {class => 'copyright'} div { "Copyright \x{00a9} 2009 WK"; };
}
