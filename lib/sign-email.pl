#!/usr/bin/perl -w
# Copyright © 2006, 2007 Jamie Zawinski <jwz@jwz.org>
#
# Permission to use, copy, modify, distribute, and sell this software and its
# documentation for any purpose is hereby granted without fee, provided that
# the above copyright notice appear in all copies and that both that
# copyright notice and this permission notice appear in supporting
# documentation.  No representations are made about the suitability of this
# software for any purpose.  It is provided "as is" without express or 
# implied warranty.
#
# Handler for emailed commands to sign@dnalounge.com.
# To install:
#  symlink it into /etc/smrsh/, then add this to /etc/aliases:
#  switcher: "|/etc/smrsh/sign-email.pl"
#
# This runs on the mail host (cerebellum) not the sign host (cerebrum).
#
# Created: 25-Nov-2006.

require 5;
use diagnostics;
use strict;

my $progname = $0; $progname =~ s@.*/@@g;
my $version = q{ $Revision: 1.4 $ }; $version =~ s/^[^0-9]+([0-9.]+).*$/$1/;

my $verbose = 0;
my $debug = 0;

my $base_url = "http://cerebrum/sign/";
my $logfile = "/var/log/signmail";


sub log_msg($)
{
  my ($msg) = @_;
  return unless $logfile;
  return if $debug;
  local *OUT;
  open (OUT, ">>$logfile") || error ("$logfile: $!");
  print OUT $msg . "\n\n";
  close OUT;
}


sub parse_msg($)
{
  my ($msg) = @_;

  my ($hdrs, $body) = ($msg =~ m/^(.*?)\n\n(.*)$/s);
  $body =~ s/\n--[ \t]*\n.*$//s;  # lose sig
  my ($subj) = ($hdrs =~ m/^Subject:[ \t]*([^\r\n]*)[ \t]*$/mi);
  my ($ct)   = ($hdrs =~ m/^Content-Type:[ \t]*([^\s;]+)/mi);
  $subj = '' unless $subj;
  $ct = 'text/plain' unless $ct;

  error ("ignoring $ct") if ($ct =~ m/^multipart/si);

  error ("ignoring $1") if ($hdrs =~ m/^(X-Mailman|X-List)/si);

  error ("ignoring subject: $subj") 
    if ($subj =~ m/failure \s notice
		  |undeliverable
		  |delivery
		  |Returned \s mail
		  |out \s of \s ( the \s )? office
		  |autoreply
		  |^Re:
		  /xsi);

  log_msg ($msg);

  $body =~ s/\s+$//m;
  $body =~ s/^[ \t]*\n+//s;

  $body = "$subj\n$body";
  $body =~ s/^[ \t]*\n//s;
  $body =~ s/\s+$//m;

  $body = "Content-Type: $ct\n$body" unless (lc($ct) eq 'text/plain');

  my @lines = split (/\n/, $body);
  error ("no text!") unless ($#lines >= 0);

  # Only send the first 3 lines to the sign.  It's ok of those lines are 
  # long, and will wrap to more than 32x4: the sign will truncate.
  #
  if ($#lines > 3) {
    @lines = @lines[0 .. 3];
  }

  my $post = 'message=' . join("\\n", @lines) . '&Add=Add' . '&truncate=yes';
  $post =~ s/%/%25/gs;

  if ($debug) {
    print STDERR "$progname: message:\n\t" . join ("\n\t", @lines) . "\n\n";
    print STDERR "$progname: post: $post\n\n";
    exit 0;
  }

  my @cmd = ("wget", "-qO/dev/null", $base_url,
             "--post-data=" . $post);
  print STDERR "$progname: exec: " . join(" ", @cmd) . "\n" if ($verbose);
  system (@cmd);
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
    elsif (m/^-./) { usage; }
    else { usage; }
  }

  my $msg = '';
  while (<>) { $msg .= $_; }
  parse_msg ($msg);
}

main();
exit 0;
