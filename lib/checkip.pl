#!/usr/local/bin/perl

# a subroutine to check for DoS attacks
# manages a DBM file of IP and time_t pairs

my $SNARKDIR = "/home/sign/snarkd";
push @INC, "$SNARKDIR/lib";

# location of the DB File
my $DBFILE="$SNARKDIR/data/posters.db";

# We only permit three posts in a 15 minute limit - might have to exclude
# the kiosk net?
my $LIMIT = 3;
my $TIMELIMIT = 900; 

use DB_File;

tie (%ip_db, DB_File, $DBFILE,O_CREAT|O_RDWR,0644) ||
    die ("Cannot open $DBFILE");

sub check_ip {
    my $searchip = shift;

    # exempt IPs here...
    if (($searchip eq "204.16.159.132") ||   # work
	($searchip eq "70.91.205.90") ||     # retina
	($searchip eq "69.36.228.130") ||   # dna - kiosk
	($searchip eq "69.36.228.131"))  {  # dna - office
      return 1;
#    } else {
#      # Only allow posting from inside DNA
#      return 2;
    }

    # Allow posting from anywhere else, but restrict to $TIMELIMIT posts
    # between posts (after the first $LIMIT posts)

    if (! $ip_db{$searchip}) { 
	$ip_db{"cnt-$searchip"} = 1;
	$ip_db{"$searchip"} = time;
	# new ip, it's okay. 
	return 1;
    } else {
	# seen it before, increment counter
	$ip_db{"cnt-$searchip"} = $ip_db{"cnt-$searchip"} + 1;
	$now = time;
	$delta = time - $ip_db{"$searchip"};

	if ( ($ip_db{"cnt-$searchip"} > $LIMIT) && ($delta < $TIMELIMIT)) { 
	    # too many posts! 
	    return 0;
	} else {
	   if ($delta > $TIMELIMIT)
	       {
		   # reset the clock for good behaviour
		   $ip_db{"cnt-$searchip"} = 1;
		   $ip_db{"$searchip"} = time;
	       }
	}
    }
    # everything ok
    1;
}


1;

