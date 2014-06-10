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
my $version = q{ $Revision: 1.9 $ }; $version =~ s/^[^0-9]+([0-9.]+).*$/$1/;

my $verbose = 0;
my $debug = 0;
my $yesterday_p = 0;

my $SNARKDIR;
BEGIN {
$SNARKDIR = "/home/sign/snarkd";
unshift @INC, "$SNARKDIR/lib";
}

use Net::LiveJournal;

require "snarklib.pl";

my $url = 'http://www.dnalounge.com/calendar/dnalounge.rss';
my $logfile = "$SNARKDIR/data/log.txt";

my $lj_acct = 'snarkatron';
my $lj_pass = '#';
my $lj_comm = 'drunkdna';

my %monthvals = (
  'jan' => 1, 'january' => 1, 'february' => 2, 'feb' => 2, 'march' => 3,
  'mar' => 3, 'april' => 4, 'apr' => 4, 'may' => 5, 'jun' => 6, 'june' => 6,
  'jul' => 7, 'july' => 7, 'august' => 8, 'aug' => 8, 'sep' => 9, 'sept' => 9,
  'september' => 9, 'oct' => 10, 'october' => 10, 'nov' => 11,
  'november' => 11, 'dec' => 12, 'december' => 12
);


sub dna_rss() {

#  my $tmpdir = ($ENV{TMPDIR} || "/tmp");
  my $tmpdir = "/home/sign/snarkd/data";
  my $cache_file = "$tmpdir/dnalounge.rss";
  my $ftime = (stat($cache_file))[9];
  my $data = '';

  # reload if the file doesn't exist, or if it's more than an hour old.
  if (!$ftime || $ftime < (time - (60 * 60))) {
    print STDERR "$progname: reloading $url\n" if ($verbose > 1);
    $data = `wget -qO- '$url'`;
    error ("no data") unless (length($data) > 100);
    unlink $cache_file;
    local *OUT;
    open (OUT, ">$cache_file") || error ("$cache_file: $!");
    print OUT $data;
    close OUT;
  } else {
    print STDERR "$progname: reusing $cache_file\n" if ($verbose > 1);
    local *IN;
    open (IN, "<$cache_file") || error ("$cache_file: $!");
    while (<IN>) { $data .= $_; }
    close IN;

  }

  return $data;
}


sub today() {
  # subtract 9 hours, so that 8am counts as the night before.
  my $t = time() - (60 * 60 * 9);
  $t -= (60 * 60 * 24) if ($yesterday_p);
  return $t;
}

sub current_event_name() {

  my $now = today();
  my @now = localtime ($now);

  my $rss = dna_rss();
  $rss =~ s/\n/ /gsi;
  $rss =~ s/(<item>)/\n$1/gsi;

  print STDERR sprintf("$progname: looking for event for %04d-%02d-%02d\n",
                       $now[5]+1900, $now[4]+1, $now[3])
    if ($verbose > 2);

  foreach (split (/\n/, $rss)) {
    next unless m/^<item/;
    my ($tag1, $title) = m@<(title)>([^<>]+)</\1>@si;
    my ($tag2, $date)  = m@<(dnalounge:date)>([^<>]+)</\1>@si;

    my ($dotm, $mon, $year) = ($date =~ m/^(\d+) ([a-z]+) (\d+)/si);
    $mon = $monthvals{lc($mon)}-1;
    $year -= 1900;
    if ($now[3] == $dotm && $now[4] == $mon && $now[5] == $year) {
      $title =~ s/^.*?:\s*//s;
      return $title;
    }
  }

  return undef;
}


sub drunkdna() {
  my $event = current_event_name();

  if (!$event) {
    print STDERR "$progname: not open today\n" if ($verbose);
    return;
  } elsif ($verbose) {
    print STDERR "$progname: current event: $event\n";
  }

  my $now = today();
  my @now = localtime ($now);

  $now[2] = 20;   # start at 8:30pm
  $now[1] = 30;
  $now[0] = 0;

  my $nowstr = sprintf("%04d %02d %02d %02d:%02d:%02d",
                       $now[5]+1900, $now[4]+1, $now[3],
                       $now[2], $now[1], $now[0]);

  print STDERR "$progname: starting at $nowstr\n" if ($verbose > 2);

  my @lines = ();

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

#      $hms .= "\n" . sprintf("%s, %s %d", $dotw, $mon, $dotm);
      $hms =~ s/(^|$)/ &nbsp; &nbsp;/gm;
      $hms =~ s/\n/<BR>/gs;

      $msg =~ s/[^\t\n -~]/%%X/g; # no binary chars allowed in LJ posts

      $msg = formatmsg_ashtml($msg);
      $msg =~ s/^(<BR>)+//si;
      $msg =~ s/(<BR>)+$//si;

      my $line = 
        (" <TR>\n" .
         "  <TD STYLE='background:#121' VALIGN=MIDDLE ALIGN=RIGHT NOWRAP>$hms</TD>\n" .
         "  <TD STYLE='background:#121' VALIGN=MIDDLE><PRE STYLE='margin:0'>$msg</PRE></TD>\n" .
         " </TR>\n");
      push @lines, $line;
    }
  }
  close IN;

  if ($#lines < 0) {
    print STDERR "$progname: no posts for $event\n" if ($verbose);
    return;
  }

  my $max_size = 63 * 1024;

  my @posts = ();

  while ($#lines >= 0) {

    my $lines = '';
    my $L = 0;
    do {
      my $line = shift @lines;
      $L += length($line);
      $lines .= $line;
    } while ($#lines >= 0 && $L < $max_size);

    next if ($L == 0);

    my $title = $event;

    my $output = 
      ("<DIV ALIGN=CENTER>\n" .
       "<TABLE BORDER=0 CELLPADDING=16 CELLSPACING=0" .
       " BGCOLOR=\"black\" WIDTH=\"100%\"><TR><TD ALIGN=CENTER>\n" .
       "<TABLE BORDER=0 CELLPADDING=6 CELLSPACING=4" .
       " STYLE='color:#2F2'>\n" .
       $lines .
       "</TABLE>\n" .
       "</TD></TR></TABLE>\n" .
       "</DIV><P>\n");

    push @posts, $output;
  }

  my $n = 0;
  my $m = $#posts+1;
  foreach my $post (@posts) {
    $n++;
    my $title = ($m == 1 ? $event : "$event (Part $n of $m)");
    my $kb = int(length($post)/1024);
    print STDERR "$progname: posting $kb KB: $title\n" if ($verbose > 1);
    if ($debug) {
      print STDOUT "$post\n<P><HR><P>\n";
    } else {
      lj_post ($title, $post);
    }
  }
}


sub lj_post($$) {
  my ($event, $html) = @_;

  my $subj = "$event Snark-a-Tron Posts";

  my $lj = Net::LiveJournal->new (user    => $lj_acct, 
                                  password => $lj_pass);
  my $entry = Net::LiveJournal::Entry->new (subject   => $subj,
                                            body      => $html,
                                            usejournal => $lj_comm
                                           );
  if (my $url = $lj->post($entry)) {
    print STDERR "$progname: OK: $url\n" if ($verbose);
  } else {
    error ("FAILED: " . $lj->errstr);
  }
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
  while ($#ARGV >= 0) {
    $_ = shift @ARGV;
    if ($_ eq "--verbose") { $verbose++; }
    elsif (m/^-v+$/) { $verbose += length($_)-1; }
    elsif ($_ eq "--debug") { $debug++; }
    elsif ($_ eq "--yesterday") { $yesterday_p++; }
    elsif (m/^-./) { usage; }
    else { usage; }
  }

  drunkdna();
}

main();
exit 0;
