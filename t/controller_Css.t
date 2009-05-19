use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'DemoApp' }
BEGIN { use_ok 'DemoApp::Controller::Css' }

ok( request('/css')->is_success, 'Request should succeed' );


