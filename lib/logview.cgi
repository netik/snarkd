#!/usr/bin/perl -w
# Copyright © 2006 Jamie Zawinski <jwz@jwz.org>
#
# Permission to use, copy, modify, distribute, and sell this software and its
# documentation for any purpose is hereby granted without fee, provided that
# the above copyright notice appear in all copies and that both that
# copyright notice and this permission notice appear in supporting
# documentation.  No representations are made about the suitability of this
# software for any purpose.  It is provided "as is" without express or 
# implied warranty.
#
# Created: 25-Nov-2006.

require 5;
use diagnostics;
use strict;

my $progname = $0; $progname =~ s@.*/@@g;
my $version = q{ $Revision: 1.6 $ }; $version =~ s/^[^0-9]+([0-9.]+).*$/$1/;

my $verbose = 0;

my $SNARKDIR;
BEGIN {
$SNARKDIR = "/home/sign/snarkd";
unshift @INC, "$SNARKDIR/lib";
}

# jwz: require DNA Lounge login
BEGIN { push @INC, "/var/www/dnalounge/utils/"; }
use dna_auth;

my $logged_in_user = dna_auth::dna_auth_demand_login(['snarkatron']);


require "snarklib.pl";

my $logfile = "$SNARKDIR/data/log.txt";

my %monthvals = (
  'jan' => 1, 'january' => 1, 'february' => 2, 'feb' => 2, 'march' => 3,
  'mar' => 3, 'april' => 4, 'apr' => 4, 'may' => 5, 'jun' => 6, 'june' => 6,
  'jul' => 7, 'july' => 7, 'august' => 8, 'aug' => 8, 'sep' => 9, 'sept' => 9,
  'september' => 9, 'oct' => 10, 'october' => 10, 'nov' => 11,
  'november' => 11, 'dec' => 12, 'december' => 12
);


sub logview($) {
  my ($days) = @_;

  my $now = time() - (60 * 60 * 24 * $days);
  my @now = localtime ($now);

  my $nowstr = sprintf("%04d %02d %02d %02d:%02d:%02d",
                       $now[5]+1900, $now[4]+1, $now[3],
                       $now[2], $now[1], $now[0]);

  my $output = '';

  $output .= "<DIV ALIGN=CENTER>\n";
  $output .= ("<TABLE BORDER=0 CELLPADDING=6 CELLSPACING=4" .
              " STYLE='color:#2F2'>\n");

  my $count = 0;
  local *IN;
  open (IN, "<$logfile") || error ("$logfile: $!");
  while (<IN>) {
    my ($dotw, $mon, $dotm, $hms, $year, $ip, $msg) = 
      m@^\[([a-z]+) ([a-z]+) +(\d+) +([\d:]+) +[a-z]+ +(\d+)\] ([\d.]+) (.*)$@si;
    if (! $msg) {
      print STDERR "$progname: unparsable: $_";
      next;
    }

    my $mm = $monthvals{lc($mon)};
    my $datestr = sprintf("%04d %02d %02d %s", $year, $mm, $dotm, $hms);

    if ($datestr gt $nowstr) {
      my ($h, $m) = ($hms =~ m/^(\d+):(\d+)/);
      if ($h == 0) { $hms = sprintf("%d:%02d AM", 12, $m); }
      elsif ($h == 12) { $hms = sprintf("%d:%02d PM", $h, $m); }
      elsif ($h >  12) { $hms = sprintf("%d:%02d PM", $h-12, $m); }
      else { $hms = sprintf("%d:%02d AM", $h, $m); }

      $hms .= "\n" . sprintf("%s, %s %d", $dotw, $mon, $dotm);
      $hms =~ s/(^|$)/ &nbsp; &nbsp;/gm;
      $hms =~ s/\n/<BR>/gs;

      $msg = formatmsg_ashtml($msg);
      $msg =~ s/^(<BR>)+//si;
      $msg =~ s/(<BR>)+$//si;

      $output .= " <TR>\n";
      $output .= "  <TD STYLE='background:#121' VALIGN=MIDDLE ALIGN=RIGHT NOWRAP>$hms</TD>\n";
      $output .= "  <TD STYLE='background:#121' VALIGN=MIDDLE><PRE STYLE='margin:0'>$msg</PRE></TD>\n";
      $output .= " </TR>\n";
      $count++;
    }
  }
  close IN;

  $output .= "</TABLE>\n";
  $output .= "</DIV><P>\n";

  $output = "<DIV ALIGN=CENTER><B>Last $days days:</B></DIV><P>\n" . $output;

  $output = 
    ("<HEAD>\n" .
     "<TITLE>DNA Lounge: Sign Log</TITLE>\n" .
     "</HEAD>\n" .
     "<BODY BGCOLOR=\"#000000\" TEXT=\"#00FF00\"\n" .
     "       LINK=\"#00DDFF\" VLINK=\"#AADD00\" ALINK=\"#FF6633\">\n" .
     "\n" .
     $output);

  print STDOUT "Content-Type: text/html\n\n";
  print STDOUT $output;
}


sub error($) {
  my ($err) = @_;
  print STDERR "$progname: $err\n";
  exit 1;
}

sub usage() {
  print STDERR "usage: $progname [--verbose]\n";
  exit 1;
}

sub main() {
  my $days = 2;

  while ($#ARGV >= 0) {
    $_ = shift @ARGV;
    if ($_ eq "--verbose") { $verbose++; }
    elsif (m/^-v+$/) { $verbose += length($_)-1; }
    elsif (m/^-./) { usage; }
    else { usage; }
  }

  logview($days);
}

main();
exit 0;
