use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'DemoApp' }
BEGIN { use_ok 'DemoApp::Controller::Js' }

ok( request('/js/prototype.js')->is_success, 'Request should succeed' );


