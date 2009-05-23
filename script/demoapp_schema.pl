#!/usr/bin/perl
use strict;
use warnings;
use FindBin;

system("$FindBin::Bin/demoapp_create.pl",
       'model'=> 'DB', 
       'DBIC::Schema' => 'DemoApp::Schema',
       'create=static', 'dbi:Pg:dbname=demoapp', 'postgres', '');
