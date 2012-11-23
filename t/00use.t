#!/usr/bin/perl

use strict;
use warnings;

use Test::More;

use_ok "IO::Pending";
use_ok "IO::Select::Buffered";

Test::More->builder->is_passing
    or BAIL_OUT "Modules will not load!";

done_testing;
