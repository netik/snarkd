#!/usr/bin/perl 

#
# Turn the sign on or off to conserve the LED's. 
#
# usage: sign_power.pl {on|off}
#
#
# J. Adams
# 10/2007
#

sub usage()
  {
    print "Usage: sign_power.pl {on|off}\n";
    exit;
  }

my $SNARKDIR;

BEGIN {
$SNARKDIR = "/home/sign/snarkd";
unshift @INC, "$SNARKDIR/lib";
unshift @INC, "$SNARKDIR/lib/Config-INI-Simple-0.01/lib";
}

my $SNARKDIR = "/home/sign/snarkd";
push @INC, "$SNARKDIR/lib";

my $CONFIGFILE = "$SNARKDIR/snark.ini";
my $mode;

if ($ARGV[0] eq "on") { 
  $mode = 2;
} elsif ($ARGV[0] eq "off") { 
  $mode = 0;
} else {
  usage();
}

# load conf
use Config::INI::Simple;
$conf = new Config::INI::Simple;
$conf->read($CONFIGFILE);

# change sign mode...

$conf->{sign}->{mode} = $mode;

$conf->write($CONFIGFILE) || die "can't write $CONFIGFILE: $!";

