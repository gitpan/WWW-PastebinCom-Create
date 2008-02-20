#!/usr/bin/env perl

use strict;
use warnings;

use Test::More tests => 7;

BEGIN {
    use_ok('Carp');
    use_ok('URI');
    use_ok('LWP::UserAgent');
    use_ok('overload');
	use_ok( 'WWW::PastebinCom::Create' );
}

diag( "Testing WWW::PastebinCom::Paste $WWW::PastebinCom::Paste::VERSION, Perl $], $^X" );

use WWW::PastebinCom::Create;

my $p = WWW::PastebinCom::Create->new;
isa_ok( $p, 'WWW::PastebinCom::Create' );
can_ok( $p, qw(new paste paste_uri error get_valid_formats) );