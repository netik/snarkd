#!/usr/bin/perl -w

#
# promoter-cgi: allow promoters/whomever to enter up to four messages 
#
# Copyright(?) 2006 John Adams <jna@retina.net>
#
# Permission to use, copy, modify, distribute, and sell this software and its
# documentation for any purpose is hereby granted without fee, provided that
# the above copyright notice appear in all copies and that both that
# copyright notice and this permission notice appear in supporting
# documentation.  No representations are made about the suitability of this
# software for any purpose.  It is provided "as is" without express or 
# implied warranty.
#

# jwz: require DNA Lounge login
BEGIN { push @INC, "/var/www/dnalounge/utils/"; }
use dna_auth;

my $logged_in_user = dna_auth::dna_auth_demand_login(['snarkatron']);


my $SNARKDIR;

BEGIN {
$SNARKDIR = "/home/sign/snarkd";
unshift @INC, "$SNARKDIR/lib";
unshift @INC, "$SNARKDIR/lib/Config-INI-Simple-0.01/lib";
}
#use lib "$SNARKDIR/lib/Config-INI-Simple-0.01/lib";

require 5;
use diagnostics;
use strict;

use Text::Wrap;

use POSIX;   # for mktime()

use HTML::TagFilter;
use Text::Template;
use Config::INI::Simple;
use CGI qw/:standard/;

# dirty word filter
require "snarkfilter.pl";
require "snarklib.pl";

# DoS protection
require "checkip.pl";


# Globals
#
my $CONFIGFILE = "$SNARKDIR/snark.ini";

my $conf;
my $query;
my $mode = '2';
my $justify = 'c';
my $st_justify = 'c';
my $wipe = 1;
my $st_wipe = 1;
my $wrap = 1;
my $st_wrap = 1;
my $cnt;
my $dwell;
my $priority = 10;
my $displayed = 0;
my @days = ('Su','M','Tu','W','Th','F','Sa');

my $hourfrm = 0;
my $minfrm   = 0;
my $hourto   = 23;
my $minto   = 59;

my @message = "";

my $invalid = 0;
my $status = "";

my $permitpub = 1;

sub initialize() {
  $query = new CGI;
  $conf = new Config::INI::Simple;

  # read configuration and init
  $conf->read($CONFIGFILE);

  # load messages from queue
  for (my $i=0; $i < 4; $i++ ) { 
    if (defined($conf->{"message0000$i"})) { 
      $message[$i] = $conf->{"message0000$i"}->{message};
    } else {
      $message[$i] = "";
    }
  }

  $cnt = $conf->{sign}->{defaultcnt};
  $dwell = $conf->{sign}->{defaultdwell};

  # Are we set to allow?
  if ($conf->{sign}->{addpage} eq "enable") {
    $permitpub = 1;
  } else {
    $permitpub = 0;
  }
}

sub handle_submission() {

  for (my $i = 0; $i < 4;$i++) { 
    $message[$i] = $query->{"message$i"}[0];

    # convert newlines
    $message[$i] =~ s/\r\n/\n/gs;  # CRLF -> LF
    $message[$i] =~ s/\r/\n/gs;    # CR   -> LF
    $message[$i] =~ s/\n/\\n/gs;   # LF   -> "\n"

# Not for promoters!
#    # get rid of dirty words
#    if ($conf->{sign}->{snarkfilter} eq 1 ) { 
#      $message[$i] = snarkFilter($message[$i]);
#    }

  }

  my $i = 0;
  foreach (@message) {
    $i++;
    $_ = snark_wrap ($_, 1);   # should promoter page auto-wrap? probably...
    # Uh, this is bogus, but let's handle the error later...
    if (!defined ($_)) {
      $_ = '';
      $status = "Message $i too long!";
      last;
    }
    if (m/(%%[^RGAXBE])/) {
      $status = "Message $i: unknown formatting code <TT>\"$1\"</TT>.";
      last;
    }
  }

  if ($status eq "") {
    $conf->read($CONFIGFILE) || die "can't read $CONFIGFILE: $!";

    # process all messgaes 
    for (my $i = 0; $i < 4; $i++) { 

      # use special IDs here. I know this is stupid. oh well. 
      # 0 = dj, 00 = song/title, 0000 = promoter
      my $lastid="0000$i";
      $conf->{"message$lastid"}->{enable} = 1;

      if ($message[$i] eq "" || $message[$i] eq "\\n") { 
	# delete it if form entry is blank
	delete $conf->{"message$lastid"};
      } else { 
	# calculate "destroyafter" time - 6am next day or 6am today if it is already after midnight but before 6am. 
	my ($second, $minute, $hour, $dayOfMonth, $month, $yearOffset, $dayOfWeek, $dayOfYear, $daylightSavings)  =
	  localtime(time);

	if ($hour > 6) { 
	  $dayOfMonth = $dayOfMonth + 1;

	  # not working: leap years!
	  my @numdaysinmonth = (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
	  if (isLeapYear($yearOffset + 1900)) { $numdaysinmonth[1] = 29; } 

	  if ($dayOfMonth > $numdaysinmonth[$month] ) { 
	    $dayOfMonth = 1;
	    $month++;
	    if ($month > 11) { $yearOffset++; $month=1; };
	  }
	} 

	my $utime = mktime(0,0,6,$dayOfMonth,$month,$yearOffset,0,$dayOfYear);

	$conf->{"message$lastid"}->{destroyat} = $utime;

        # jwz: let dwell be the number of lines in the message plus 1.
        # (2 secs for 1 line msg, 5 secs for 4 line.)
        {
          my @L = split(/\n|\\n/, $message[$i]);
          $dwell = $#L + 2;
        }

	# construct the new record
	$conf->{"message$lastid"}->{dwell} = $dwell;
	$conf->{"message$lastid"}->{priority} = 100;
	$conf->{"message$lastid"}->{cnt} = 0;
	$conf->{"message$lastid"}->{displayed} = 0;
	$conf->{"message$lastid"}->{justify} = 'l';
	$conf->{"message$lastid"}->{message} = $message[$i];
	$conf->{"message$lastid"}->{extcmd} = "";
	$conf->{"message$lastid"}->{wrap} = 0;
	$conf->{"message$lastid"}->{wipe} = 1;
	$conf->{"message$lastid"}->{days} = join(':',@days);
	
	$conf->{"message$lastid"}->{hourfrm} = $hourfrm;
	$conf->{"message$lastid"}->{hourto} = $hourto;
	$conf->{"message$lastid"}->{minfrm} = $minfrm;
	$conf->{"message$lastid"}->{minto} = $minto;
	
	$conf->{"message$lastid"}->{remote_ip} = $ENV{'REMOTE_ADDR'};
      }
    }
#      # append to log.
#      open(F,"+>>$SNARKDIR/data/log.txt");
#      my $t=`/bin/date`;
#      chomp $t;
#      
#      my $ip = $ENV{'REMOTE_ADDR'};
#      print F "[$t] $ip (promo) " . $message[$i]\n";
#      close(F);

    $permitpub = $query->{"permitpub"}[0];

    # update the permit/deny setting
    if ($permitpub eq "1") {
      $conf->{sign}->{addpage} = "enable";
    } else { 
      $conf->{sign}->{addpage} = "off";
    }

    # refresh the file
    $conf->write($CONFIGFILE) || die "can't write $CONFIGFILE: $!";;
    
    my $msgs = '';
    foreach (@message) {
#      if ($_ ne "" && $_ ne "\\n") { 
	my $msg = formatmsg_ashtml($_);
	my $pad = ' ' x 32;  # dammit! "width:32em" doesn't work!!
	$msgs .= "<PRE STYLE='border:1px solid; padding:1em;'>$pad<BR>$msg<BR><BR></PRE><P>";
#      }
    }
    $msgs = "<TABLE><TR><TD ALIGN=LEFT>$msgs</TD></TR></TABLE>";

    $status .= "<B>Update Complete!</B><P><I>Public Posting: " . $conf->{sign}->{addpage} . "</i> </p>";
    $status .= "<B>Messages Updated:</B>";
    $status .= "<P>$msgs";
  }
}

sub print_html($) {
  my ($form_submitted_p) = @_;

print header;
#  print header,
#    start_html(-title=>'DNA Lounge: Sign: Promoter Messages',
#	       -expires=>'now');

  my $file = ($form_submitted_p
              ? "$SNARKDIR/lib/promoter-done.tpl"
              : "$SNARKDIR/lib/promoter-add.tpl");
  my $template = Text::Template->new(SOURCE => $file,
                                     DELIMITERS => [ '[@--', '--@]' ]
                                    )
    or die "Couldn't construct template: $Text::Template::ERROR";
  
  my $pwrstat = ($conf->{sign}->{mode} ? "On" : "Off");

  # populate template
  my @msgs2 = @message;
  foreach (@msgs2) { s/\\n/\n/gs; }       # unquote '\n' to real CR
  my $tmplhash = { status => $status,
		   message0 => $msgs2[0],
		   message1 => $msgs2[1],
		   message2 => $msgs2[2],
		   message3 => $msgs2[3],
		   pwrstat => $pwrstat,
		   permitpub => $query->checkbox(-name=>"permitpub",
						 -checked=>$permitpub,
						 -value=>1,
						 -label=>'Allow the public to post messages on the sign')
                 };

  # put html to screen
  print  $template->fill_in(HASH => $tmplhash);
  print end_form;
  print end_html . "\n";
}

sub handle_power($) { 
  my ($state) = @_;
  # turns the sign on or off based on the value of $state

  if ($state eq 0) { 
    # turnoff
    $conf->{sign}->{mode} = 0;
    $conf->{sign}->{addpage} = "off";
    $status  = "Sign turned <B>OFF</B>. This will take 3-5 seconds.";
  } else { 
    # turnon
    $conf->{sign}->{mode} = 2;
    $conf->{sign}->{addpage} = "enable";
    $status  = "Sign turned <B>ON</B>. This will take 3-5 seconds.";
  }
  $conf->write($CONFIGFILE) || die "can't write $CONFIGFILE: $!";;



}

sub handle_emergency() {
  # set posting to off
  $conf->{sign}->{addpage} = "off";

  # destroy all messages with priority >= 1000 (public)
  
  foreach my $k (keys %{$conf}) {
    if ($k =~ /^message(\d+)/) {
      if ($conf->{$k}->{priority} >= 1000) {
	delete $conf->{$k};
      }
    }
  }
  # write it out
  $conf->write($CONFIGFILE) || die "can't write $CONFIGFILE: $!";;

  $status = "<B>EMERGENCY OVERRIDE</B><P>All public messages deleted and public posting turned off!";
}

sub main() {
  initialize();

  if ($query->{"turnon"}) { 
    handle_power(1);
    print_html(1);
    return;
  }

  if ($query->{"turnoff"}) { 
    handle_power(0);
    print_html(1);
    return;
  }

  if ($query->{"emergency"}) { 
    handle_emergency();
    print_html(1);
    return;
  }

  if ($query->{"Update"}) { 
    handle_submission();
    print_html(1);
  } else {
    print_html(0);
  }
}

main();
