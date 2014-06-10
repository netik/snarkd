#!/usr/bin/perl 

#
# sign housekeeping
#
# Reset the allow page and permit access to the sign 
# runs from cron at 6am. 
# 
# Also remove any lingering DJ entries 
# 
# J. Adams
# 11/2006
#

my $SNARKDIR;

BEGIN {
$SNARKDIR = "/home/sign/snarkd";
unshift @INC, "$SNARKDIR/lib";
unshift @INC, "$SNARKDIR/lib/Config-INI-Simple-0.01/lib";
}

my $SNARKDIR = "/home/sign/snarkd";
push @INC, "$SNARKDIR/lib";

my $CONFIGFILE = "$SNARKDIR/snark.ini";

# load conf
use Config::INI::Simple;
$conf = new Config::INI::Simple;
$conf->read($CONFIGFILE);

# enable public posting, put sign into normal "ON" mode. 
$conf->{sign}->{addpage} = "enable";

# disabling this - this will be handled by sign_power in cron instead. 
# turn sign on
#$conf->{sign}->{mode} = 2;

# delete the dj message if there is one from last night...

delete $conf->{message0};
delete $conf->{message00000};
delete $conf->{message00001};
delete $conf->{message00002};
delete $conf->{message00003};


$conf->write($CONFIGFILE) || die "can't write $CONFIGFILE: $!";

