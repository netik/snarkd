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

my $query = new CGI;
print header;

my $choice =  $query->{'id'};

print start_html;
print "Your vote for choice #" . $choice . " has been counted by the sign! Thanks!\n";
print end_html;


