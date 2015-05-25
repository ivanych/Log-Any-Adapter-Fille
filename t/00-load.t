#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Log::Any::Adapter::Fille' ) || print "Bail out!\n";
}

diag( "Testing Log::Any::Adapter::Fille $Log::Any::Adapter::Fille::VERSION, Perl $], $^X" );
