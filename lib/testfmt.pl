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
# Command line tool for testing the centering and %%-syntax to HTML conversion routines.
#
# Created: 29-Nov-2006.

require 5;
use diagnostics;
use strict;

use Text::Wrap;

my $progname = $0; $progname =~ s@.*/@@g;
my $version = q{ $Revision: 1.2 $ }; $version =~ s/^[^0-9]+([0-9.]+).*$/$1/;

my $verbose = 0;

my $SNARKDIR;
BEGIN {
$SNARKDIR = "/home/sign/snarkd";
unshift @INC, "$SNARKDIR/lib";
}

require "snarklib.pl";

sub testfmt($) {
  my ($msg) = @_;
  print STDOUT "\n$msg\n\n";

  my $line = '#==============##==============#';

  $msg = snark_wrap ($msg, 1, 1);
  error ("message too long") unless $msg;

  my $L;
  {
    my $msg3 = $msg;
    $msg3 =~ s/\\n/\n/gs;
    $msg3 =~ s/%%X/#/gs;
    $msg3 =~ s/%%.//gs;
    $L = length ($msg3);
  }

  my $msg2 = $msg;
  $msg2 =~ s/\\n/\n/gs;
  $msg2 = "$line\t$L bytes\n$msg2";
  $msg2 =~ s/^/\t/gm;
  print STDOUT "$msg2\n\n";

  $msg2 =~ s/%%X/#/gs;
  $msg2 =~ s/%%.//gs;
  print STDOUT "$msg2\n\n";

  $msg = formatmsg_ashtml ($msg);
  $msg2 = $msg;
  $msg2 =~ s/(<BR>)/\n/gsi;
  $msg2 = "$line\t$L\n$msg2\n$line\n";
  $msg2 =~ s/^/\t/gm;
  print "$msg2\n";
}


sub error($) {
  my ($err) = @_;
  print STDERR "$progname: $err\n";
  exit 1;
}

sub usage() {
  print STDERR "usage: $progname [--verbose] msg ...\n";
  exit 1;
}

sub main() {
  my @args = ();
  while ($#ARGV >= 0) {
    $_ = shift @ARGV;
    if ($_ eq "--verbose") { $verbose++; }
    elsif (m/^-v+$/) { $verbose += length($_)-1; }
    elsif (m/^-./) { usage; }
    else { push @args, $_; }
  }
  usage unless ($#args >= 0);
  foreach (@args) { testfmt($_); }
}

main();
exit 0;
