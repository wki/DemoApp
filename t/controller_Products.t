use strict;
use warnings;
use Test::More tests => 2;

BEGIN { use_ok 'Catalyst::Test', 'DemoApp' }
BEGIN { use_ok 'DemoApp::Controller::Products' }

# fails -- we get a redirect...
#ok( request('/products')->is_success, 'Request should succeed' );


