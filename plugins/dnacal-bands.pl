#!/usr/bin/perl -w
# Copyright © 2006-2013 Jamie Zawinski <jwz@dnalounge.com>
#
# Permission to use, copy, modify, distribute, and sell this software and its
# documentation for any purpose is hereby granted without fee, provided that
# the above copyright notice appear in all copies and that both that
# copyright notice and this permission notice appear in supporting
# documentation.  No representations are made about the suitability of this
# software for any purpose.  It is provided "as is" without express or 
# implied warranty.
#
# Created: 19-Nov-2006.

require 5;
use diagnostics;
use strict;

my $progname = $0; $progname =~ s@.*/@@g;
my $version = q{ $Revision: 1.12 $ }; $version =~ s/^[^0-9]+([0-9.]+).*$/$1/;

my $verbose = 0;

my $url = 'http://www.dnalounge.com/calendar/dnalounge.rss';


my %monthvals = (
  'jan' => 1, 'january' => 1, 'february' => 2, 'feb' => 2, 'march' => 3,
  'mar' => 3, 'april' => 4, 'apr' => 4, 'may' => 5, 'jun' => 6, 'june' => 6,
  'jul' => 7, 'july' => 7, 'august' => 8, 'aug' => 8, 'sep' => 9, 'sept' => 9,
  'september' => 9, 'oct' => 10, 'october' => 10, 'nov' => 11,
  'november' => 11, 'dec' => 12, 'december' => 12
);


sub dna_rss() {

  my $tmpdir = (-d "/home/sign/snarkd/data"
                ?  "/home/sign/snarkd/data"
                :  ($ENV{TMPDIR} || "/tmp"));
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
  return $t;
}


# In RSS fields, all entities are encoded.
# and the sign can't handle Latin1.
# so we need to translate "&amp;uuml;" to "&uuml;" to "u".
#
sub html_unquote($) {
  my ($s) = @_;
  if ($s) {
    $s =~ s/&amp;/&/gs;
    $s =~ s/&lt;/</gs;
    $s =~ s/&gt;/>/gs;
    $s =~ s/&([a-zA-Z])(uml|acute|grave|cedil);/$1/gs;
  }
  return $s;
}

# HTML in RSS fields is entity-encoded, since HTML knows more entities than
# RSS does.  And then HTML also uses entity-encoding.  So this means that
# we need to decode every RSS field twice, to get it down to raw characters.
#
sub rss_unquote($) {
  my ($s) = @_;
  return html_unquote (html_unquote ($s));
}


sub dna_calendar($) {
  my ($mode) = @_;

  my $now = today();
  my @now = localtime ($now);

  my $tmr = $now + (60 * 60 * 24);  # tomorrow
  my @tmr = localtime ($tmr);

  my $rss = dna_rss();
  $rss =~ s/\n/ /gsi;
  $rss =~ s/(<item>)/\n$1/gsi;
  my @lines = ();

  my $nowstr = sprintf("%04d %02d %02d", $now[5]+1900, $now[4]+1, $now[3]);
  my $tmrstr = sprintf("%04d %02d %02d", $tmr[5]+1900, $tmr[4]+1, $tmr[3]);

  my $line_length = 33;  # we omit the colon late, so allow one extra column

  my $maxlen = 0;

  my $this_event = undef;

  foreach (split (/\n/, $rss)) {
    next unless m/^<item/;
    my ($tag1, $title)  = m@<(dnalounge:title)>([^<>]+)</\1>@si;
    my ($tag2, $ltitle) = m@<(dnalounge:live_title)>([^<>]+)</\1>@si;
    my ($tag3, $date)   = m@<(dnalounge:date)>([^<>]+)</\1>@si;
    my ($tag4, $band)   = m@<(dnalounge:band)[^<>]*>([^<>]+)</\1>@si;
    $title  = rss_unquote ($title);
    $ltitle = rss_unquote ($ltitle) if ($ltitle);
    $band   = rss_unquote ($band);

    my ($dotm, $mon, $year, $dotw) = 
      ($date =~ m/^(\d+) ([a-z]+) (\d+) \(([a-z]+)\)/si);
    my $mm = $monthvals{lc($mon)};

    my $datestr = sprintf("%04d %02d %02d", $year, $mm, $dotm);
    my $tomorrow_p = 0;

    if ($datestr lt $nowstr) {  # past event
      next;
    } elsif ($datestr eq $nowstr) {
      $this_event = $title;
      $this_event =~ s/^.*?:\s*//s;
      next;
    } elsif ($datestr eq $tmrstr) {  # tomorrow
      $tomorrow_p = 1;
    }

    if ($mode eq 'events') {
      # nothing special

    } elsif ($mode eq 'bands') {
      if (defined ($ltitle)) {
        # If there is a live_title, then this is a live show by fiat.
        $title = $ltitle;
        $title =~ s/^(.*) \(at (.*)\)$/$1 \@ $2/s;  # reformat
      } else {
        # If we want bands, and this event doesn't have one, skip it.
        next unless $band;
        next if ($band =~ m/^smash-up derby$/si);  # skip, too frequent
        $title =~ s/^(.*)$/$band @ $1/
          if ($title !~ m/$band/);
      }

    } elsif ($mode eq 'next') {
      my $tt = $title;
      $tt =~ s/^.*?:\s*//s;
      next unless ($this_event && $tt eq $this_event);

    } else {
      error ("unknown mode: $mode");
    }

    $title =~ s/\band\b/&/gsi;  # abbreviate "and the" by 2 more chars

    $title =~ s/^(Bootie) SF/$1/gsi;  # shorten.

    if ($tomorrow_p) {
      $title = "  Tomorrow: $title";
    } else {
      $title = sprintf ("%s %s %-2d: %s", $dotw, $mon, $dotm, $title);
    }

    if ($mode eq 'next') {
      my ($dd, $tt) = ($title =~ m/^(.*?)\s*:\s*(.*)$/si);
      $tt = "Next $tt";
      push @lines, '';
      push @lines, $tt;
      $title = $dd;
    }

    $title =~ s/^(.{$line_length}).*$/$1/s;  # truncate at 32 chars

    # If there are 5 or fewer chars after the @, lose it.
    $title =~ s/ \@.{0,5}$//;

    $maxlen = length($title) if (length($title) > $maxlen);

    push @lines, $title;

    if (($mode eq 'next' && $#lines >= 0) ||
        $#lines > 2) {
      last;
    }
  }

  # Clean up some whitespace alignment goofiness...
  $lines[0] =~ s/ (Tomorrow):/$1 :/
    if ($lines[1] && $lines[1] =~ m/ \d :/);

  # center the lines horizontally as a unit
  my $pad = int (($line_length - $maxlen) / 2);
  foreach (@lines) {

    if ($mode eq 'next') {
      $pad = int (($line_length - length($_)) / 2);
    }

    if ($pad > 0) {
      $_ = (' ' x $pad) . $_;
    }
    # add colors
    s/^/%%R/si;  # red dates
    s/:/%%A/si;  # amber text (delete colon)
    s/\s*$//s;
  }

  my $result = join("\n", @lines);
#  $result =~ s/\n/\\n/gs;
  $result .= "\n" if ($result);
  print STDOUT $result;
}

sub error($) {
  my ($err) = @_;
  print STDERR "$progname: $err\n";
  exit 1;
}

sub usage() {
  print STDERR "usage: $progname [--verbose] [--events | --bands | --next]\n";
  exit 1;
}

sub main() {
  my $mode = 'events';
  while ($#ARGV >= 0) {
    $_ = shift @ARGV;
    if ($_ eq "--verbose") { $verbose++; }
    elsif (m/^-v+$/) { $verbose += length($_)-1; }
    elsif (m/^--?events?$/) { $mode = 'events'; }
    elsif (m/^--?bands?$/)  { $mode = 'bands'; }
    elsif (m/^--?next$/)    { $mode = 'next'; }
    elsif (m/^-./) { usage; }
    else { usage; }
  }
  dna_calendar($mode);
}

main();
exit 0;
