#!/usr/bin/env perl
use strict;
use warnings;

use lib '/Users/u1022/proj/DemoApp/lib';
use DemoApp;

DemoApp->setup_engine('PSGI');
my $app = sub { DemoApp->run(@_) };

