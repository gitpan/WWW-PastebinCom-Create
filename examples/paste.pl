#!/usr/bin/env perl

use strict;
use warnings;
use lib '../lib';
use WWW::PastebinCom::Create;

die "Usage: perl paste.pl <name_of_the_file_to_paste>\n"
    unless @ARGV;

my $file_to_paste = shift;

my $What = do {
    local $/;
    open my $fh, '<', $file_to_paste
        or die "Failed to open $file_to_paste ($!)";

    <$fh>;
};

my $paste = WWW::PastebinCom::Create->new;

$paste->paste( text => $What )
    or die "Error: " . $paste->error;

print "Your paste can be found on $paste\n";

=pod

Usage: perl paste.pl <file_to_paste>

=cut