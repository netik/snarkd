#!/usr/local/bin/perl

#  0    1    2     3     4    5     6     7     8
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime;

$ampm = "AM";
$year += 1900;
@days = ('Sun','Mon','Tue','Wed','Thu','Fri','Sat');

# stupid am/pm rules. 24 hour rulez.
if ($hour > 11) { $ampm="PM" };
if ($hour > 12) { $hour = $hour - 12; }
if ($hour == 0) { $hour = 12; }

print sprintf("%%%%R%s %%%%G$mon/$mday/$year %d:%02d:%02d $ampm \n",$days[$wday],$hour,$min,$sec)


