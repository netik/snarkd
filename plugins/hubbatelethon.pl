#!/usr/bin/perl

# this is to make a fake telethon ticker for the hubba hubba revue
# it should reach $1mil by the end of the night. 4h or so? 

sub center
  {
    my $maxlen=40;
    my $str = $_[0];
    my $pad = 16-(int (length($str) / 2));
    return (' ' x $pad) . $str;
  }


sub format_currency { 
  local $_  = shift;
  1 while s/^(-?\d+)(\d{3})/$1,$2/;
  return $_;
}



my $amt = 0;

if ( -f "/tmp/hubba" ) { 
  open(F,"</tmp/hubba");
  $amt = <F>;
  close(F);
} else { 
  $amt = 0; 
}

srand(time);

$amt = $amt + int(rand(500));
print center("HUBBA HUBBA REVUE\n");
print center("%%RFighting Restless Leg Syndrome\n");
print center("\$" . format_currency($amt) ."\n");
print center("Thank you for your donation!\n");


open(F,">/tmp/hubba");
print F $amt;
close(F);
