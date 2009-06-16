# products/uritest.pl


sub RUN {
    h1 {'URI Test page'};
    
    with { class => 'list', style => {width => '950px'} }
    table {
        thead {
            trow {
                th { 'description' };
                th { 'code' };
                th { 'URI' };
                th { 'comment' };
            };
        };
        
        tbody {
            trow {
                tcol { 'invalid relative path 1' };
                tcol { q{c->uri_for('xxx')} };
                tcol { c->uri_for('xxx') };
                tcol { 'expecting to die' };
            };
            trow {
                tcol { 'invalid relative path 2' };
                tcol { q{c->uri_for('../dummy/xxx')} };
                tcol { c->uri_for('../dummy/xxx') };
                tcol { 'expecting to die' };
            };
            trow {
                tcol { 'valid relative path 1' };
                tcol { q{c->uri_for('detail')} };
                tcol { c->uri_for('detail') };
                tcol { '' };
            };
            trow {
                class 'lined';
                tcol { 'valid relative path 2' };
                tcol { q{c->uri_for('../login/register')} };
                tcol { c->uri_for('../login/register') };
                tcol { '' };
            };
            
            trow {
                tcol { 'invalid absolute path' };
                tcol { q{c->uri_for('/products/xxx')} };
                tcol { c->uri_for('/products/xxx') };
                tcol { 'expecting to die' };
            };
            trow {
                class 'lined';
                tcol { 'valid absolute path 2' };
                tcol { q{c->uri_for('/login/register')} };
                tcol { c->uri_for('/login/register') };
                tcol { '' };
            };
            
            trow {
                tcol { 'invalid construction using "action"' };
                tcol { q{c->uri_for(c->action('dummy'))} };
                tcol { c->uri_for(c->action('dummy')) };
                tcol { 'expecting to die' };
            };
            trow {
                tcol { 'valid construction using "action"' };
                tcol { q{c->uri_for(c->action('show'))} };
                tcol { c->uri_for(c->action('show')) };
                tcol { '' };
            };
            trow {
                class 'lined';
                tcol { 'valid construction using "action"' };
                tcol { q{c->uri_for(c->action('detail'))} };
                tcol { c->uri_for(c->action('detail')) };
                tcol { 'wrong URI, action is chained' };
            };

            trow {
                tcol { 'invalid construction using "action_for"' };
                tcol { q{c->uri_for(c->controller->action_for('dummy'))} };
                tcol { c->uri_for(c->controller('Products')->action_for('dummy')) };
                tcol { 'not usable inside a View, wrong URI' };
            };
            trow {
                tcol { 'valid construction using "action"' };
                tcol { q{c->uri_for(c->controller->action_for('show'))} };
                tcol { c->uri_for(c->controller('Products')->action_for('show')) };
                tcol { 'not usable inside a View' };
            };
            trow {
                class 'lined';
                tcol { 'valid construction using "action"' };
                tcol { q{c->uri_for(c->controller->action_for('detail'))} };
                tcol { c->uri_for(c->controller('Products')->action_for('detail')) };
                tcol { 'not usable inside a View' };
            };
            
            trow {
                tcol { 'invalid construction using "action_for"' };
                tcol { q{c->uri_for(c->controller('Products')->action_for('dummy'))} };
                tcol { c->uri_for(c->controller('Products')->action_for('dummy')) };
                tcol { 'wrong URI' };
            };
            trow {
                tcol { 'valid construction using "action"' };
                tcol { q{c->uri_for(c->controller('Products')->action_for('detail'))} };
                tcol { c->uri_for(c->controller('Products')->action_for('detail')) };
                tcol { '' };
            };
            trow {
                class 'lined thick';
                tcol { 'valid construction using "action"' };
                tcol { q{c->uri_for(c->controller('Products')->action_for('detail'),42)} };
                tcol { c->uri_for(c->controller('Products')->action_for('detail'),42) };
                tcol { '' };
            };



            trow {
                tcol { 'invalid construction using a shortcut' };
                tcol { q{c->uri_for('Products::dummy')} };
                tcol { c->uri_for('Products::dummy') };
                tcol { 'wrong URI' };
            };
            trow {
                tcol { 'valid construction using a shortcut' };
                tcol { q{c->uri_for('Products::show')} };
                tcol { c->uri_for('Products::show') };
                tcol { '' };
            };
            trow {
                tcol { 'valid construction using a shortcut' };
                tcol { q{c->uri_for('Products::show',127)} };
                tcol { c->uri_for('Products::show',127) };
                tcol { '' };
            };
            trow {
                tcol { 'valid construction using a shortcut' };
                tcol { q{c->uri_for('Products::detail')} };
                tcol { c->uri_for('Products::detail') };
                tcol { '' };
            };
            trow {
                class 'lined thick';
                tcol { 'valid construction using a shortcut' };
                tcol { q{c->uri_for('Products::detail',42)} };
                tcol { c->uri_for('Products::detail',42) };
                tcol { '' };
            };



            trow {
                tcol { 'invalid construction with absolute path' };
                tcol { q{c->uri_for_action('/products/dummy')} };
                tcol { '- dies -' };
                tcol { '' };
            };
            trow {
                tcol { 'invalid construction with relative path' };
                tcol { q{c->uri_for_action('products/dummy')} };
                tcol { '- dies -' };
                tcol { '' };
            };
            trow {
                tcol { 'valid construction relative path 1' };
                tcol { q{c->uri_for_action('index')} };
                tcol { c->uri_for_action('index') };
                tcol { '' };
            };
            trow {
                tcol { 'valid construction relative path 2' };
                tcol { q{c->uri_for_action('products/index')} };
                tcol { c->uri_for_action('products/index') };
                tcol { '' };
            };
            trow {
                tcol { 'valid construction relative path 3' };
                tcol { q{c->uri_for_action('products/detail')} };
                tcol { c->uri_for_action('products/detail') };
                tcol { 'action is chained' };
            };
            trow {
                tcol { 'valid construction relative too long path' };
                tcol { q{c->uri_for_action('products/index/test')} };
                tcol { '- dies -' };
                tcol { '' };
            };
            trow {
                tcol { 'valid construction relative with params' };
                tcol { q{c->uri_for_action('products/detail',42)} };
                tcol { c->uri_for_action('products/detail',42) };
                tcol { 'action is chained' };
            };
            trow {
                tcol { 'valid construction relative too long with params' };
                tcol { q{c->uri_for_action('products/detail/test',42)} };
                tcol { '- dies -' };
                tcol { '' };
            };
            trow {
                tcol { 'valid construction absolute path 1' };
                tcol { q{c->uri_for_action('/products/index')} };
                tcol { c->uri_for_action('/products/index') };
                tcol { '' };
            };
            trow {
                tcol { 'valid construction absolute path 2' };
                tcol { q{c->uri_for_action('/products/detail')} };
                tcol { c->uri_for_action('/products/detail') };
                tcol { 'action is chained' };
            };
            trow {
                tcol { 'valid construction with parameters' };
                tcol { q{c->uri_for_action('/products/detail',42)} };
                tcol { c->uri_for_action('/products/detail',42) };
                tcol { 'action is chained' };
            };
        };
    };
}

# with { href => c->uri_for(c->controller->action_for('register')) }
# with { href => c->uri_for(c->action('register')) }

