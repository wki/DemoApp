use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'DemoApp' }
BEGIN { use_ok 'DemoApp::Controller::Persons' }

ok( request('/persons')->is_success, 'Request should succeed' );


