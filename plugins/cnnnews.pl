#!/usr/local/bin/perl

use XML::RSS::Parser::Lite;
use LWP::Simple;

# use cache here.
my $URL="http://rss.cnn.com/rss/cnn_topstories.rss";
my $CACHEFILE = "/var/www/cerebrum/snark/plugins/data/cnn.rss";

my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
       $atime,$mtime,$ctime,$blksize,$blocks)
    = stat($CACHEFILE);

$cacheage = time() - $mtime;

if ($cacheage > 1200) { 
    # get new data
    my $xml = get($URL);
    open (RSSFEED,">$CACHEFILE");
    print RSSFEED $xml;
    close(RSSFEED);
} 

open (RSSFEED,"<$CACHEFILE");
undef $/;
$xml = <RSSFEED>;
close(RSSFEED);


my $rp = new XML::RSS::Parser::Lite;
$rp->parse($xml);
        
#print $rp->get('title') . " " . $rp->get('url') . " " . $rp->get('description') . "\n";

%MONTH = (    "Jan" =>1,
	      "Feb" =>2,
	      "Mar" =>3,
	      "Apr" =>4,
	      "May" =>5,
	      "Jun" =>6,
	      "Jul" =>7,
	      "Aug" =>8,
	      "Sep" =>9,
	      "Oct" =>10,
	      "Nov" =>11,
	      "Dec" =>12 );
    

if (@ARGV[0] > 0) { 
    $index = @ARGV[0];
}


for (my $i = 0; $i < $rp->count(); $i++) {
    my $it = $rp->get($i);

    if ($i > $index) { 

    $title = $it->get('title');

    if ($title =~ m/^(.*?) (.*?) \((.*?)\): (.*)/) {
	if ($2 < 10) { $sp = "0"; } else { $sp =""; }
	$title = "$3%%G " . $MONTH{$1} . "/$sp" . $2 . " %%A" . $4;
    }

    print $title . " " . $it->get('dnalounge:date') . " " . $it->get('dnalounge:genre') ."\\n";
    $cnt++;
    if ($cnt == 4) { print "\n"; exit; } ;
    }
}

