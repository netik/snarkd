#!/usr/bin/perl -w 
#
# Snarkadmin - admin the snark-a-tron
# 
# John Adams <jna@retina.net>
#
# Permission to use, copy, modify, distribute, and sell this software and its
# documentation for any purpose is hereby granted without fee, provided that
# the above copyright notice appear in all copies and that both that
# copyright notice and this permission notice appear in supporting
# documentation.  No representations are made about the suitability of this
# software for any purpose.  It is provided "as is" without express or 
# implied warranty.
#
# Created 11/2006
#

my $SNARKDIR;

BEGIN {
$SNARKDIR = "/home/sign/snarkd";
unshift @INC, "$SNARKDIR/lib";
unshift @INC, "$SNARKDIR/lib/Config-INI-Simple-0.01/lib";
}
#use lib "$SNARKDIR/lib/Config-INI-Simple-0.01/lib";

use Text::Template;
use Config::INI::Simple;
use CGI qw/:standard :cgi-lib/;


# jwz: require DNA Lounge login
BEGIN { push @INC, "/var/www/dnalounge/utils/"; }
use dna_auth;

my $logged_in_user = dna_auth::dna_auth_demand_login(['snarkatron']);


require "snarklib.pl";

my $query = new CGI;

my $CONFIGFILE = "$SNARKDIR/snark.ini";
my $CONFIGBACKUPFILE = "$SNARKDIR/snark-default.ini";

my $conf = new Config::INI::Simple;

# read configuration and init
$conf->read($CONFIGFILE);
$conf->{status}->{lastcgirun} = time;

# used in snarkadmin.tpl:
$addpagegroup = undef;
$blockgroup = undef;
$snarkfiltercb = undef;
$modegroup = undef;
$st_justifygroup = undef;
$st_wordwraphtml = undef;
$st_wipehtml = undef;
$justifygroup = undef;
$wordwraphtml = undef;
$wipehtml = undef;
$enablehtml = undef;
$dayshtml = undef;
$timehtml = undef;
$extcmd = undef;
$queuehdr = undef;


sub numerically {
    $a <=> $b;
}

# init vars if this is a new config file
if ($conf->{status}->{lastshown} eq "") {
    $conf->{status}->{lastshown} = 0;
};

if ($conf->{status}->{lastid} eq "") {
    # last id is the last message id added to the system

    # Messages starting with '0'  are reserved message IDs
    # for the DJ subsystem, so we'll start at #1
    $conf->{status}->{lastid} = 1;
};

# Update the clock
$conf->{status}->{lastcgirun} = time;


# defaults
$staticmsg ="S N A R K - A - T R O N\n%%RVERSION 1.00\n%%AJ. Adams <jna\@retina.net>";
$addtitle = "Add message to Queue";
$addbutton = "Add";
$mode = '1';
$addpage = 'enable';
$block = 'off';
$snarkfilter = 0;
$justify = 'l';
$st_justify = 'c';
$wipe = 1;
$st_wipe = 1;
$wrap = 0;
$st_wrap = 1;
$dwell = 4;
$cnt = 0;
$defaultcnt = 0;
$defaultdwell = 4;
$priority = 50;
$enable = 1;
$displayed = 0;
@days = ('Su','M','Tu','W','Th','F','Sa');

$hourfrm = 0;
$minfrm   = 0;
$hourto   = 23;
$minto   = 59;

$signhourfrm = 0;
$signminfrm   = 0;
$signhourto   = 23;
$signminto   = 59;

$destroyat  = 0;

$MIN = ['00','15','30','45','59'];
$HRS = [0..23];

$status = "Like I care what you have to say, anyway.";

# recall the stored config
if ($conf->{sign}->{staticmsg} ne "") { 
    $staticmsg = $conf->{sign}->{staticmsg};
}
if ($conf->{sign}->{mode} ne "") { 
    $mode = $conf->{sign}->{mode};
}

if ($conf->{sign}->{defaultcnt} ne "") { 
    $defaultcnt = $conf->{sign}->{defaultcnt};
}

if ($conf->{sign}->{defaultdwell} ne "") { 
    $defaultdwell = $conf->{sign}->{defaultdwell};
}

if ($conf->{sign}->{addpage} ne "") { 
    $addpage = $conf->{sign}->{addpage};
}

if ($conf->{sign}->{block} ne "") { 
    $block = $conf->{sign}->{block};
}

if ($conf->{sign}->{snarkfilter} ne "") { 
    $snarkfilter = $conf->{sign}->{snarkfilter};
}

if ($conf->{sign}->{static_justify} ne "") { 
    $st_justify = $conf->{sign}->{static_justify};
}
if ($conf->{sign}->{static_wipe} && $conf->{sign}->{static_wipe} ne "") { 
    $st_wrap = $conf->{sign}->{static_wipe};
}
if ($conf->{sign}->{static_wrap} ne "") { 
    $st_wipe = $conf->{sign}->{static_wrap};
}


if ($conf->{sign}->{onfrm_hh} ne "") { 
  $signhourfrm = $conf->{sign}->{onfrm_hh};
}

if ($conf->{sign}->{onfrm_mm} ne "") { 
  $signminfrm = $conf->{sign}->{onfrm_mm};
}

if ($conf->{sign}->{onto_hh} ne "") { 
  $signhourto = $conf->{sign}->{onto_hh};
}

if ($conf->{sign}->{onto_mm} ne "") { 
  $signminto = $conf->{sign}->{onto_mm};
}



# get rid of newlines
if ($query->{'newmsg'}[0]) {
  $query->{'newmsg'}[0] =~ s/\r//g;
  $query->{'newmsg'}[0] =~ s/\n/\\n/g;
}
if ($query->{'staticmsg'}) {
  $query->{'staticmsg'}[0] =~ s/\n/\\n/g;
  $query->{'staticmsg'}[0] =~ s/\r//g;
}


if ($query->{'delete'}) {
    my $id=$query->{'delete'}[0];
    delete $conf->{"message$id"};

    $status="$id deleted.\n";

    # dump and erase. 
    $conf->write($CONFIGFILE) || die "can't write $CONFIGFILE: $!";
    $conf->read($CONFIGFILE) || die "can't read $CONFIGFILE: $!";
}


# --- show the form ---
if ($query->{'Commit'} || $query->{'CommitBackup'}) {
    # save sign settings
    $conf->{sign}->{defaultcnt} = $query->{'defaultcnt'}[0];
    $conf->{sign}->{defaultdwell} = $query->{'defaultdwell'}[0];
    $conf->{sign}->{mode} = $query->{'mode'}[0];
    $conf->{sign}->{addpage} = $query->{'addpage'}[0];
    $conf->{sign}->{block} = $query->{'block'}[0];
    $conf->{sign}->{snarkfilter} = $query->{'snarkfilter'}[0];

    $conf->{sign}->{onfrm_hh} = $query->{'signhourfrm'}[0];
    $conf->{sign}->{onfrm_mm} = $query->{'signminfrm'}[0];
    $conf->{sign}->{onto_hh} = $query->{'signhourto'}[0];
    $conf->{sign}->{onto_mm} = $query->{'signminto'}[0];

    $staticmsg = $query->{'staticmsg'}[0];
    $staticmsg =~ s/\n/\\n/g;
    $staticmsg =~ s/\r//g;

    $st_justify = $query->{'st_justify'}[0];
    $st_wipe = $query->{'st_wipe'}[0];
    $st_wrap = $query->{'st_wrap'}[0];

    $conf->{sign}->{staticmsg} = $staticmsg;
    $conf->{sign}->{static_justify} = $st_justify;
    $conf->{sign}->{static_wipe} = $st_wipe;
    $conf->{sign}->{static_wrap} = $st_wrap;

    $status = "Your changes have been committed.";
    $conf->write($CONFIGFILE) || die "can't write $CONFIGFILE: $!";

    if ($query->{'CommitBackup'}) {
      $conf->write($CONFIGBACKUPFILE) || die "can't write $CONFIGFILE: $!";
    }
}

# TODO: EDIT MODE
if ($query->{'edit'}) {

    $msgid = $query->{edit}[0];
    $addtitle="Edit Message #" . $msgid . " <a href=\"?\">(cancel)</a>";
    $addbutton = "Edit";

    # load vars into current add message area below
    $enable = $conf->{"message$msgid"}->{enable};
    $dwell = $conf->{"message$msgid"}->{dwell};
    $priority = $conf->{"message$msgid"}->{priority};
    $cnt = $conf->{"message$msgid"}->{cnt};
    $displayed = $conf->{"message$msgid"}->{displayed};
    $justify = $conf->{"message$msgid"}->{justify};
    $newmsg = $conf->{"message$msgid"}->{message};
    $extcmd = $conf->{"message$msgid"}->{extcmd};
    $wrap = $conf->{"message$msgid"}->{wrap};
    $wipe = $conf->{"message$msgid"}->{wipe};

    # unwrap newlines for the form
    $newmsg =~ s/\\n/\n/gs;

# needs fix (fix what? --jna) 
    @days = split(/:/,$conf->{"message$msgid"}->{days});
    $minfrm = $conf->{"message$msgid"}->{minfrm};
    $minto = $conf->{"message$msgid"}->{minto};
    $hourfrm = $conf->{"message$msgid"}->{hourfrm};
    $hourto = $conf->{"message$msgid"}->{hourto};

    $destroyat = $conf->{"message$msgid"}->{destroyat} || 0;

    # set special edit variable 
    # change text
}

if ($query->{'Update'}) { 
    # update enable checkboxes and write to config

    # iterate through elements of enables. If it's changed, we know 
    # a checkbox has been checked or unchecked.
    foreach $k (keys %{$conf}) {
	if ($k =~ /^(message.*)/) { 	
	    if ($query->param("enable-$1") != $conf->{$k}->{enable}) { 
		$conf->{$k}->{enable} = $query->param("enable-$1");
	    }
	}
    }
    $conf->write($CONFIGFILE) || die "can't write $CONFIGFILE: $!";;
    # refresh the file
    $conf->read($CONFIGFILE) || die "can't write $CONFIGFILE: $!";
}

if ($query->{'Add'}) { 
    # add a new message
    $conf->{status}->{lastid}++;
    my $lastid=$conf->{status}->{lastid}; 
    
    $conf->{"message$lastid"}->{enable} = $query->{'enable'}[0];
    $conf->{"message$lastid"}->{dwell} = $query->{'dwell'}[0];
    $conf->{"message$lastid"}->{priority} = $query->{'priority'}[0];
    $conf->{"message$lastid"}->{cnt} = $query->{'cnt'}[0];
    $conf->{"message$lastid"}->{displayed} = $query->{'displayed'}[0];
    $conf->{"message$lastid"}->{justify} = $query->{'justify'}[0];
    $conf->{"message$lastid"}->{message} = $query->{'newmsg'}[0];
    $conf->{"message$lastid"}->{extcmd} = $query->{'extcmd'}[0];
    $conf->{"message$lastid"}->{wrap} = $query->{'wrap'}[0];
    $conf->{"message$lastid"}->{wipe} = $query->{'wipe'}[0];
    $conf->{"message$lastid"}->{days} = join(':',@{$query->{days}});

    $conf->{"message$lastid"}->{hourfrm} = $query->{'hourfrm'}[0];
    $conf->{"message$lastid"}->{minfrm} = $query->{'minfrm'}[0];
    $conf->{"message$lastid"}->{hourto} = $query->{'hourto'}[0];
    $conf->{"message$lastid"}->{minto} = $query->{'minto'}[0];

    $conf->{"message$msgid"}->{destroyat} = $query->{'destroyat'}[0];

    $conf->write($CONFIGFILE) || die "can't write $CONFIGFILE: $!";;

    # refresh the file
    $conf->read($CONFIGFILE) || die "can't write $CONFIGFILE: $!";
    $status = "Message added.\n";
}


if ($query->{'Edit'}) { 
    # edit existing msg
    my $msgid=$query->{"msgid"}[0]; 

    $conf->{"message$msgid"}->{enable} = $query->{'enable'}[0];
    $conf->{"message$msgid"}->{dwell} = $query->{'dwell'}[0];
    $conf->{"message$msgid"}->{priority} = $query->{'priority'}[0];
    $conf->{"message$msgid"}->{cnt} = $query->{'cnt'}[0];
    $conf->{"message$msgid"}->{displayed} = $query->{'displayed'}[0];
    $conf->{"message$msgid"}->{justify} = $query->{'justify'}[0];
    $conf->{"message$msgid"}->{message} = $query->{'newmsg'}[0];
    $conf->{"message$msgid"}->{extcmd} = $query->{'extcmd'}[0];
    $conf->{"message$msgid"}->{wrap} = $query->{'wrap'}[0];
    $conf->{"message$msgid"}->{wipe} = $query->{'wipe'}[0];
    $conf->{"message$msgid"}->{days} = join(':',@{$query->{days}});

    $conf->{"message$msgid"}->{hourfrm} = $query->{'hourfrm'}[0];
    $conf->{"message$msgid"}->{minfrm} = $query->{'minfrm'}[0];
    $conf->{"message$msgid"}->{hourto} = $query->{'hourto'}[0];
    $conf->{"message$msgid"}->{minto} = $query->{'minto'}[0];

    $conf->write($CONFIGFILE) || die "can't write $CONFIGFILE: $!";;

    # refresh the file
    $conf->read($CONFIGFILE) || die "can't write $CONFIGFILE: $!";
    $status = "Message added.\n";


    # Instead of re-printing the form, just issue a redirect back to the
    # edit page.  That way any time you are looking at the list of messages,
    # you can hit "reload" without fear of re-submitting whatever junk is
    # still hanging around in our form data.
    #
    # (Probably there's some 'use CGI' way of doing a redirect, but I can't
    # be bothered to find out.)
    #
    my $url = "http://$ENV{HTTP_HOST}$ENV{REQUEST_URI};";
    $url =~ s/\?.*$//;
    print STDOUT ("Status: 302\n" .
                  "Location: $url\n" .
                  "Content-Type: text/html\n". 
                  "\n" .
                  $status);
    exit 0;
}


# list out the queue, only if we're not editing.
if (! $query->{"edit"}) { 
    $queuehdr = "<div id=\"header\">Current Message Queue (Last displayed message is in blue)</div><P>";
    $queue .="<TABLE width=100%>";
    $queue .= "<TH width=60>Id</TH><TH width=60>Priority</TH><TH>Message</TH><TH width=20>Flags</th><th>Valid</th><TH width=20>Enabled?</TH><TH>Dwell</TH><TH width=60>Count</TH><TH width=60>Viewed</TH><TH width=60></TH><TH width=60></TH>";

   
foreach my $k (sort {
    my $ap = $conf->{$a}->{priority} || 0;
    my $bp = $conf->{$b}->{priority} || 0;
    if ($ap == $bp) {
      $a cmp $b
    } else {
      $ap <=> $bp;
    }
  } keys %{$conf}) { 
    my $flags = "";

    if ($k =~ /^message(\d+)/) { 

	if ($1 eq $conf->{status}->{lastshown}) { $style = "currentmsg"; } else { $style = "inqueue"; }

	if ($conf->{$k}->{wipe} eq 1) { $flags .= "w" };
	if ($conf->{$k}->{wrap} eq 1) { $flags .= "W" };
	$flags .= $conf->{$k}->{justify};
	$validtod = $conf->{$k}->{days};

# jwz: assume all preformatted
#	my $JUST = "LEFT";
#	if ($conf->{$k}->{justify} eq "r") { $JUST="RIGHT"; } 
#	if ($conf->{$k}->{justify} eq "c") { $JUST="CENTER"; } 

	$queue .= "<TR><TD id=$style align=center>$1</TD>" .
	    "<TD id=$style align=center>" . $conf->{$k}->{priority}  . "</TD>" .
	    "<TD id=$style align=LEFT><PRE STYLE='margin:2px;'>".formatmsg_ashtml($conf->{$k}->{message}). "</PRE></TD>" . 
	    "<TD id=$style align=center>" . $flags  . "</TD>" .
	    "<TD id=$style align=center>" . $validtod . "<BR>" . 
	    $conf->{$k}->{hourfrm} . ":" .$conf->{$k}->{minfrm} . " - " .
	    $conf->{$k}->{hourto} . ":" .$conf->{$k}->{minto} .
	    "</TD>" .
	    "<TD id=$style align=center>" .
            $query->checkbox(-name=>"enable-$k",
			     -checked=>$conf->{$k}->{enable},
			     -value=>1,
			     -label=>"") .  "</TD>" .
	    "<TD id=$style align=center>" . $conf->{$k}->{dwell}  . "</TD>" .
	    "<TD id=$style align=center>" . $conf->{$k}->{cnt}  . 
 	    "</TD>" .
	    "<TD id=$style align=center>" . $conf->{$k}->{displayed}  . "</TD>" .
	    "<TD id=$style align=center><a href=\"?edit=$1\">Edit</a></TD>" . 
	    "<TD id=$style align=center><a href=\"?delete=$1\">Delete</a></TD>" .
	    "</TR>\n";

	$totmsg++;
      }
  }
    
    $queue .="</TABLE>";
    if ( $totmsg == 0 ) { 
      $queue = "<P>No messages in queue. Make with the snark, already.</P>" 
    };

  }


print header,
    start_html(-title=>'DNA Lounge: Sign Admin',
	       -expires=>'now',
	       -style=>{'src'=>'../snark.css'});

print start_form;

my $template = Text::Template->new(SOURCE => "$SNARKDIR/lib/snarkadmin.tpl")
    or die "Couldn't construct template: $Text::Template::ERROR";

$addpagegroup = radio_group(-name=>'addpage',
			 -values=>['off','hold','enable'],
			 -labels=>{'off'=>'Deny All','hold'=>'Held for Approval','enable'=>'Enable'},
			 -default=>$addpage);

$blockgroup = radio_group(-name=>'block',
			 -values=>['off','pri1000'],
			 -labels=>{'off'=>'None','pri1000'=>'All public messages'},
			 -default=>$block);

$snarkfiltercb = checkbox(-name=>"snarkfilter",
			  -checked=>$snarkfilter,
			  -value=>1,
			  -label=>"On");

$modegroup = radio_group(-name=>'mode',
			 -values=>['0','1','2','3'],
			 -labels=>{'0'=>'Off','1'=>'Static','2'=>'Cycle','3'=>'Random'},
			 -default=>$mode);


$st_justifygroup = radio_group(-name=>'st_justify',
			    -values=>['l','c','r'],
			    -labels=>{'l'=>'Left','c'=>'Center','r'=>'Right'},
			    -default=>$st_justify);

$st_wordwraphtml = checkbox_group(-name=>'st_wrap',-values=>['1'],-default=>$st_wrap,
			       -labels=>{'1'=>'Wrap text to subsequent lines (don\'t mix with multiline strings!)'});

$st_wipehtml  = checkbox_group(-name=>'st_wipe',-values=>1,-default=>$st_wipe,
			    -labels=>{'1'=>'Clear display before showing new message'});


$justifygroup = radio_group(-name=>'justify',
			    -values=>['l','c','r'],
			    -labels=>{'l'=>'Left','c'=>'Center','r'=>'Right'},
			    -default=>$justify);

$wordwraphtml = checkbox_group(-name=>'wrap',-values=>['1'],-default=>$wrap,
			       -labels=>{'1'=>'Wrap text to subsequent lines'});

$wipehtml  = checkbox_group(-name=>'wipe',-values=>1,-default=>$wipe,
			    -labels=>{'1'=>'Clear display before showing new message'});

$enablehtml = checkbox_group(-name=>'enable',-values=>['1'],-default=>$wrap,
			     -labels=>{'1'=>''},
			     -default=>$enable);

$dayshtml = checkbox_group(-name => 'days',
			   -labels => {'0' =>'Sun','1' =>'Mon','2' =>'Tue','3' =>'Wed','4' =>'Thu','5' =>'Fri','6' =>'Sat'},
			   -values => ['Su','M','Tu','W','Th','F','Sa'],
			   -defaults=>\@days);

$timehtml = 
    popup_menu('hourfrm',$HRS,$hourfrm) . ":"  .
    popup_menu('minfrm',$MIN,$minfrm) . " to " .
    popup_menu('hourto',$HRS,$hourto) . ":"  .
    popup_menu('minto',$MIN,$minto) ;

$signtimehtml = 'shut up';
$signtimehtml = 
    popup_menu('signhourfrm',$HRS,$signhourfrm) . ":"  .
    popup_menu('signminfrm',$MIN,$signminfrm) . " to " .
    popup_menu('signhourto',$HRS,$signhourto) . ":"  .
    popup_menu('signminto',$MIN,$signminto) ;


# display html

$text = $template->fill_in();
print $text;
print end_form;

