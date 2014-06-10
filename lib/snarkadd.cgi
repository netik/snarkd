#!/usr/bin/perl -w

#
# Snarkadd - restricted add script for external users
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

use HTML::TagFilter;
use Text::Template;
use Config::INI::Simple;
use CGI qw/:standard/;
use Text::Wrap;

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

my $message = "";
my $chkmsg = "";

my $invalid = 0;
my $status = "";

sub get_lastfive() {
  # get the last five items posted to the snarkatron by snarkd
  my $out = ("<P><DIV ALIGN=CENTER><DIV STYLE=\"width:27em; border: solid 1px\">" .
             "<TABLE WIDTH=\"100%\" BORDER=0 CELLPADDING=4 CELLSPACING=2>");

  # jwz: let's put the oldest at the top instead of the bottom
#  for (my $i=1;$i<6;$i++) { 
  for (my $i=6;$i>=1;$i--) { 
    
    my $msg = $conf->{lastfive}->{"msg$i"};
    next unless ($msg);
    my ($t, $m) = split(/\|/, $msg);
    $t =~ s/^.*,\s*//s; # lose date portion
    $m = formatmsg_ashtml($m);
    $m =~ s/^(<BR>)+//si;
    $out .= ("<TR><TD NOWRAP VALIGN=TOP BGCOLOR=\"#002200\">$t</TD>" .
             "<TD NOWRAP BGCOLOR=\"#002200\"><PRE STYLE='margin:2px'>$m" .
             "</PRE></TD></TR>\n");
  }
  
  $out .= "</TABLE></DIV></DIV><P>\n";
  
  return $out;
}


sub initialize() {
  $query = new CGI;
  $conf = new Config::INI::Simple;

  # read configuration and init
  $conf->read($CONFIGFILE);

  $cnt = $conf->{sign}->{defaultcnt};
  $dwell = $conf->{sign}->{defaultdwell};
}

sub handle_submission() {

  $message = $query->{"message"}[0];
  # convert newlines
  $message =~ s/\r\n/\n/gs;  # CRLF -> LF
  $message =~ s/\r/\n/gs;    # CR   -> LF
  $message =~ s/\n/\\n/gs;   # LF   -> "\n"

  my $truncate_p = $query->{"truncate"};

  # get rid of dirty words
  if ($conf->{sign}->{snarkfilter} eq 1 ) { 
    $message = snarkFilter($message);
  }
  
  $message = snark_wrap ($message, 1, $truncate_p);

  # Uh, this is bogus, but let's handle the error later...
  if (!defined ($message)) {
    $message = ('TOO LONG ' x 30);
  }


    # chk msg never includes formatting.
  $chkmsg = $message;
  $chkmsg =~ s/%%X/#/g;
  $chkmsg =~ s/%%.//g;
  $chkmsg =~ s/\\n/\n/g;
  
  if ($chkmsg =~ m/^\s*$/s) { 
    $invalid = 1;
    $status="Error: No message.";
  }
  
  my $ip_status = check_ip($ENV{'REMOTE_ADDR'});  # 0, 1, or 2

  if ($ip_status == 0) {
    $invalid = 1;
    $status = "Too many messages from your IP (" .$ENV{'REMOTE_ADDR'} . ") Try again in 15 minutes.";
  } elsif ($ip_status == 2) {
    $invalid = 1;
    $status = "Sorry, posting is only allowed from inside DNA Lounge!";
  }


#  if ($message =~ /AMBER ALERT/i) { 
  if ($chkmsg =~
      m/A[^A-Z]*M[^A-Z]*B[^A-Z]*[EA]?[^A-Z]*R.*A[^A-Z]*L[^A-Z]*E?[^A-Z]*R/i) { 
    $status = "Fucking stop it, Amber.  Seriously.";
    $invalid=1;
  }

  # verify no duplication
  foreach my $k (keys %{$conf}) { 
    # ignore internal vars in Config::INI - this sucks. 
    if ($k =~ /^message/ ) { 
      if (defined $conf->{$k}) {
	if (defined ($conf->{$k}->{"message"})) { 
          my $m1 = $conf->{"$k"}->{"message"};
          my $m2 = $message;
          # strip formatting and all non-alpha characters to compare.
          $m1 =~ s/%%.//gs; $m1 =~ s/\\n/\n/gsi; $m1 =~ s/[^A-Z]//gsi;
          $m2 =~ s/%%.//gs; $m2 =~ s/\\n/\n/gsi; $m2 =~ s/[^A-Z]//gsi;
	  if (uc($m1) eq uc($m2)) {
	    $invalid = 1;
	    $status = "Error: A similar message already exists in the queue.";
	  }
	}
      }
    }
  }
  
  # don't let anyone, ever say last call
  if ($chkmsg =~ /last\s+call/i) { 
    $invalid = 1;
  }
  
  # Fuck you, Strangelove.
  if ($chkmsg =~ m/( strange \s* love
		   | \b cat'?s \b
		   | \b cat \s* pclub \b
		   | \b julie'?s
		   | \b annie'?s
		   )
		  /xsi) { 
    $status = "Stop SPAMMING our sign, asshole.<BR>This isn't here to give you free advertising.";
    $invalid=1;
  }


  # when botnets attack!
  if ($chkmsg =~ m/\bHREF\b/si) { 
    $status = "You smell like a robot. Get lost.";
    $invalid=1;
  }


  if ($conf->{sign}->{addpage} eq "off") { 
    $invalid = 1;
    $status = "Sorry, public posting is not allowed right now.";
  }

  if ($message =~ m/(%%[^RGAXBE])/) {
    $invalid = 1;
    $status = "Error: unknown formatting code <TT>\"$1\"</TT>.";
  }

  if ($status eq "" && $invalid eq 1) {
    $status = "Message is too long or invalid.";
  }

  if ($status eq "") {
    # check length of message, after converting multi-byte sequences to single-byte.
    if (length($chkmsg) > 128) {
      $status = "Message is too long.";
    }
  }

  if ($status eq "") {

    # increment ID
    $conf->read($CONFIGFILE) || die "can't read $CONFIGFILE: $!";
    $conf->{status}->{lastid}++;
    my $lastid=$conf->{status}->{lastid}; 
    
    # set it
    if ($conf->{sign}->{addpage} eq "enable" ) { 
      $conf->{"message$lastid"}->{enable} = 1;
    } else {
      $conf->{"message$lastid"}->{enable} = 0;
    }
    
    # jwz: let dwell be the number of lines in the message plus 1.
    # (2 secs for 1 line msg, 5 secs for 4 line.)
    {
      my @L = split(/\n|\\n/, $message);
      $dwell = $#L + 2;
    }

    # construct the new record
    $conf->{"message$lastid"}->{dwell} = $dwell;
    $conf->{"message$lastid"}->{priority} = 1000; # bottom of the barrel !
    $conf->{"message$lastid"}->{cnt} = $cnt;
    $conf->{"message$lastid"}->{displayed} = 0;
    $conf->{"message$lastid"}->{justify} = 'l';
    $conf->{"message$lastid"}->{message} = $message;
    $conf->{"message$lastid"}->{extcmd} = "";
    $conf->{"message$lastid"}->{wrap} = 0;
    $conf->{"message$lastid"}->{wipe} = 1;
    $conf->{"message$lastid"}->{days} = join(':',@days);
    
    $conf->{"message$lastid"}->{hourfrm} = $hourfrm;
    $conf->{"message$lastid"}->{hourto} = $hourto;
    $conf->{"message$lastid"}->{minfrm} = $minfrm;
    $conf->{"message$lastid"}->{minto} = $minto;
    
    $conf->{"message$lastid"}->{remote_ip} = $ENV{'REMOTE_ADDR'};
    
    # refresh the file
    $conf->write($CONFIGFILE) || die "can't write $CONFIGFILE: $!";;
    
    # append to log.
    open(F,"+>>$SNARKDIR/data/log.txt");
    my $t=`/bin/date`;
    chomp $t;
    
    my $ip = $ENV{'REMOTE_ADDR'};
    print F "[$t] $ip $message\n";
    close(F);
    
    my $msg2 = formatmsg_ashtml($message);
      my $pad = ' ' x 32;  # dammit! "width:32em" doesn't work!!
    $msg2 = "<PRE STYLE='border:1px solid; padding:1em;'>$pad<BR>$msg2<BR><BR></PRE><P><BR>";
    $msg2 = "<TABLE><TR><TD ALIGN=LEFT>$msg2</TD></TR></TABLE>";

    $status = "<B>Message added:</B><P>$msg2";
  }
}


sub print_html($) {
  my ($form_submitted_p) = @_;

print header;
#  print header,
#    start_html(-title=>'DNA Lounge: Sign',
#	       -expires=>'now',
# 	       -style=>{'src'=>'snark.css'});

# jwz: WHAT THE FUCK BEAVIS.
$conf->{sign}->{addpage} = 'off';

  my $file = ($conf->{sign}->{addpage} eq "off"
	      ? "$SNARKDIR/lib/spoiler.tpl"
              : ($form_submitted_p
                 ? "$SNARKDIR/lib/snarkdone.tpl"
                 : "$SNARKDIR/lib/snarkadd.tpl"));

  my $template = Text::Template->new(SOURCE => $file,
                                     DELIMITERS => [ '[@--', '--@]' ]
                                    )
    or die "Couldn't construct template: $Text::Template::ERROR";

  # assemble last5
  my $lastfive = get_lastfive();

  # populate template
  my $tmplhash = { status => $status, 
                   lastfive => $lastfive
                 };

  # put html to screen
  print  $template->fill_in(HASH => $tmplhash);

  print end_form;
  print end_html . "\n";
}

sub main() {
  initialize();

  if ($query->{"Add"}) { 
    handle_submission();
    print_html(1);
  } else {
    print_html(0);
  }
}

main();
