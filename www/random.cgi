#!/usr/bin/perl -w
#
#
# get a random message from the snarkatron
#
# text "snark" to 41411 to get it
#

require 5;
use strict;
use diagnostics;
use CGI qw/:standard/;

my $SNARKDIR;

BEGIN {
$SNARKDIR = "/home/sign/snarkd";
unshift @INC, "$SNARKDIR/lib";
unshift @INC, "$SNARKDIR/lib/Config-INI-Simple-0.01/lib";
} 

use Tie::File;

tie my @file, "Tie::File", "$SNARKDIR/data/log.txt";


print header,
      start_html('Random Snark');


my $index = int(rand @file);
my $line = $file[$index];

# remove formatting
$line =~ s/%%[A-Z]//g;

if ($line =~ /\[(.*)\] ([0-9.]+) (.*)/) {
	my $tod = $1;
	my $msg = $3;

	$msg =~ s/\\n//g; 
	$msg =~ s/ +/ /g;

	print $msg . " (" . $tod . " #" . $index . ")";
}


print end_html;


