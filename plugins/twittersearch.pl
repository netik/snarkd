#!/usr/bin/perl
#
# pull a single keyword from the Twitter search API
# 
# John Adams <jna@twitter.com>
# 8/18/2009
#
# I wrote this while flying in a plane at 32,000 feet. really. 

use XML::RSS::Parser::Lite;
use LWP::Simple;
use URI::URL;
use Text::Wrap;
use Data::Dumper;

BEGIN {
$SNARKDIR = "/home/sign/snarkd";
unshift @INC, "$SNARKDIR/lib";
unshift @INC, "$SNARKDIR/lib/Config-INI-Simple-0.01/lib";
}

# dirty word filter
require "snarkfilter.pl";
require "snarklib.pl";
my $query = $ARGV[0];

if ($query eq "") { 
  print "%%RNo query!";
  exit;
}

my $url = URI::URL->new("http://search.twitter.com/search.rss?q=" . $query);
my $xml = get($url->as_string);
my $twuser = "unknown";

my $rp = new XML::RSS::Parser::Lite;
$rp->parse($xml);

# change this if you want a diff item, here we're taking the 1st because twitter
# sorts in reverse order.
my $n;
my $item;
srand();

$n = int(rand($rp->count())) + 0 ;
$item = $rp->get($n);
my $cnt = 0;

# no retweets, only original content
while (($item->get("title") =~ /^RT /) && ($cnt < $rp->count())) {
   $n = int(rand($rp->count())) + 0 ;
   $item = $rp->get($n);
   $cnt++;
}

if ($cnt >= $rp->count()) {
    $item = $rp->get(0); 
}

# Twitter's Search RSS API doesn't have a seperate field for this so
# we have to derive it from the Tweet's URL
if ($item->get("url") =~ m#http://twitter.com/(\w+)/#) { 
  $twuser = $1;
}

my $msg = "no matches.";

if ($item->get("title") ne "") { 
    $msg =  "%%G@" . $twuser . ": ";

  $msg .= $item->get("title");
  $msg =~ s/\s+/ /g; 
  $msg =~ s/\t//g; 

  # fixup unicode stuffz
  $msg =~ s/\&quot;/\"/g;
  $msg =~ s/\&amp;/\&/g;
  $msg =~ s/\&copy/\(c\)/g;

  $msg = snarkFilter($msg);
  $msg = snark_wrap ($msg, 0, 1);
}

print $msg . "\n";




