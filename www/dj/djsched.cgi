#!/usr/bin/perl 

#
# djsched - fill out the DJ schedule on the sign
# 
# J. Adams
# 11/2006
#
require 5;

# jwz: require DNA Lounge login
BEGIN { push @INC, "/home/store/public/include/"; }
use dna_auth;

{
  my @perms = ('snarkatron');
  my $perms = \@perms;
  $perms = undef;  # #### not yet implemented
  my $logged_in_user = dna_auth::dna_auth_demand_login($perms);
}


my $SNARKDIR;

BEGIN {
$SNARKDIR = "/home/sign/snarkd";
unshift @INC, "$SNARKDIR/lib";
unshift @INC, "$SNARKDIR/lib/Config-INI-Simple-0.01/lib";
}

use HTML::TagFilter;
use Text::Template;
use Config::INI::Simple;
use CGI qw/:standard/;

require "$SNARKDIR/lib/snarklib.pl";

my $query = new CGI;

my $CONFIGFILE = "$SNARKDIR/snark.ini";
my $conf = new Config::INI::Simple;

# read configuration and init
$conf->read($CONFIGFILE);

print header,
    start_html(-title=>'Snarkatron DJ Schedule Entry',
	       -expires=>'now',
 	       -style=>{'src'=>'../snark.css'});

# Defaults
$title = "DJ SCHEDULE";
$mode = '1';
$justify = 'c';
$st_justify = 'c';
$wipe = 1;
$st_wipe = 1;
$wrap = 1;
$st_wrap = 1;
$dwell = 12;
$cnt = 0;
$priority = 1;
$enable = 1;
$displayed = 0;
@days = ('Su','M','Tu','W','Th','F','Sa');

$hourfrm = 0;
$minfrm   = 0;
$hourto   = 23;
$minto   = 59;

# schedule defaults
$time[1] = "9:00P";
$time[2] = "10:00P";
$time[3] = "11:00P";
$time[4] = "12:00A";
$time[5] = "1:00A";
$time[6] = "2:00A";


sub center
  {
    my ($rowsize,$line) = @_;
    my $n = ($rowsize / 2 )  - (length($line) / 2);
    $t2 = (' ' x $n) . $line;
    return $t2;
  }

# restore if we can...
for ($i=1;$i<7;$i++) { 
    if ($conf->{dj}->{"time$i"} ne "") {
	$time[$i] = $conf->{dj}->{"time$i"};
    }

    if ($conf->{dj}->{"name$i"} ne "") {
	$djname[$i] = $conf->{dj}->{"name$i"};
    }
}

if ($conf->{dj}->{"title"} ne "") {
    $title = $conf->{dj}->{title};
}

# done with restore, handle buttons...

if ($query->{"Remove"}) {
    $status = "DJ schedule message removed from queue.";
    delete $conf->{"message00"};    
    $conf->write($CONFFILE) || die "can't write!";
}

if ($query->{"Save"}) { 
    $title = $query->{"title"}[0];
    $time[1] = $query->{"time1"}[0];
    $time[2] = $query->{"time2"}[0];
    $time[3] = $query->{"time3"}[0];
    $time[4] = $query->{"time4"}[0];
    $time[5] = $query->{"time5"}[0];
    $time[6] = $query->{"time6"}[0];
    $djname[1] = $query->{"djname1"}[0];
    $djname[2] = $query->{"djname2"}[0];
    $djname[3] = $query->{"djname3"}[0];
    $djname[4] = $query->{"djname4"}[0];
    $djname[5] = $query->{"djname5"}[0];
    $djname[6] = $query->{"djname6"}[0];

    $message = "%%A" . center(32,"$title") . "\\n";

    for ($i=1;$i<4;$i++) { 
	$message = $message .
	    "%%R" . sprintf("%6s",$time[$i]) . " %%G" . sprintf("%8s",$djname[$i]) . " " . 
	    "%%R" . sprintf("%6s",$time[$i+3]) . " %%G" . sprintf("%8s",$djname[$i+3]) . "\\n";
    }

    $message =~ s/^\s+//g;
    $message =~ s/\s+$/ /g;
    
    $conf->read($CONFFILE) || die "can't read!";
    
    # In this case, we're updating message #0, always. We don't care
    # how many mesages are installed. 
    $lastid="00";
    
    # set it
    $conf->{"message$lastid"}->{enable} = 1;
    $conf->{"message$lastid"}->{dwell} = $dwell;
    $conf->{"message$lastid"}->{priority} = 1; 
    $conf->{"message$lastid"}->{cnt} = 0;
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
    
    # remember the DJs and event details
    # So we can edit them later...

    $conf->{dj}->{title} = $title;
    for ($i=1;$i<7;$i++) { 
	$conf->{dj}->{"time$i"} = $time[$i];
	$conf->{dj}->{"name$i"} = $djname[$i];
    }

    # refresh the file
    $conf->write($CONFFILE) || die "can't write!";;
    
    $status = "Message added :<BR>" . formatmsg_ashtml($message) . "</font>";

}

print start_form;

my $template = Text::Template->new(SOURCE => "$SNARKDIR/lib/djsched.tpl")
    or die "Couldn't construct template: $Text::Template::ERROR";

$text = $template->fill_in();

print $text;
print end_form;

print end_html;
