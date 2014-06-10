#!/usr/bin/perl 

#
# Snarkadd - restricted add script for external users
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

sub center
  {
    my ($rowsize,$line) = @_;
    my $n = ($rowsize / 2 )  - (length($line) / 2);
    $t2 = (' ' x $n) . $line;
    return $t2;
  }

my $query = new CGI;

my $CONFIGFILE = "$SNARKDIR/snark.ini";
my $SETLIST    = "$SNARKDIR/data/setlist.txt";

my $conf = new Config::INI::Simple;


# read configuration and init
$conf->read($CONFIGFILE);

print header,
    start_html(-title=>'Snarkatron DJ Add Page',
	       -expires=>'now',
 	       -style=>{'src'=>'../snark.css'});

# Defaults
$mode = '1';
$justify = 'c';
$st_justify = 'c';
$wipe = 1;
$st_wipe = 1;
$wrap = 1;
$st_wrap = 1;
$dwell = 15;
$cnt = 0;
$priority = 1;
$enable = 1;
$displayed = 0;
@days = ('Su','M','Tu','W','Th','F','Sa');

$hourfrm = 0;
$minfrm   = 0;
$hourto   = 23;
$minto   = 59;

if ($query->{"Clear"}) { 
    $status = "Setlist Cleared.";
    open(SL,">$SETLIST");
    close(SL);
}


if ($query->{"Remove"}) {
    $status = "DJ message removed from queue.";
    delete $conf->{"message0"};    
    $conf->write($CONFFILE) || die "can't write!";
}

if ($query->{"Add"}) { 
    $djname = $query->{djname}[0];
    $band = $query->{band}[0];

    $sngtitle = $query->{sngtitle}[0];

    $message= "%%A" . center(32,"Now  Playing") . "\\n" .
	"%%A" . center(32,"$djname"). "\\nArtist: %%R" . $band . "\\n Title: %%R" . $sngtitle;

    # add to setlist
    open(SL,">>$SETLIST");
    #  0    1    2     3     4    5     6     7     8
    ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime;
    
    $ampm = "AM";
    $year += 1900;
    
    # stupid am/pm rules. 24 hour rulez.
    if ($hour > 11) { $ampm="PM" };
    if ($hour > 12) { $hour = $hour - 12; }
    if ($hour == 0) { $hour = 12; }

    $time = sprintf("%d/$mday/$year %d:%02d $ampm",$mon+1,$hour,$min);
    print SL "$time\t$djname\t$band\t$sngtitle\n";
    close(SL);

    $message = $message;
    
    $message =~ s/^\s+//g;
    $message =~ s/\s+$/ /g;
    
    # remove html
    my $tf = new HTML::TagFilter;
    $message = $tf->filter($message);
    
    # increment ID
    $conf->read($CONFFILE) || die "can't read!";
    $conf->{status}->{lastid}++;
    
    # In this case, we're updating message #0, always. We don't care
    # how many mesages are installed. 
    $lastid=0;
    
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


    # set auto delete so we never have to worry about lingering dj messages
    $conf->{"message$lastid"}->{destroyat} = time() + 240; 

    $conf->{"message$lastid"}->{hourfrm} = $hourfrm;
    $conf->{"message$lastid"}->{hourto} = $hourto;
    $conf->{"message$lastid"}->{minfrm} = $minfrm;
    $conf->{"message$lastid"}->{minto} = $minto;
    
    # refresh the file
    $conf->write($CONFFILE) || die "can't write!";;
    
    $status = "Message added : <font color=green>$message</font>";
    
    $status =~ s/%%G/<\/font><font color=green>/g;
    $status =~ s/%%R/<\/font><font color=red>/g;
    $status =~ s/%%A/<\/font><font color=yellow>/g;
}

print start_form;

my $template = Text::Template->new(SOURCE => "$SNARKDIR/lib/djadd.tpl")
    or die "Couldn't construct template: $Text::Template::ERROR";


# get setlist and reverse it's order
open (SL,"<$SETLIST");
@lines = <SL>;
close (SL);

if ($#lines != -1)  {
$setlist = "<div id=header>Set List</div><BR><TABLE width=100%><TR>
<TH>Time</TH>
<TH>DJ</TH>
<TH>Artist</TH>
<TH>Title</TH>
</TR>";

foreach $line (reverse (@lines)) { 
    my ($s_time,$s_dj,$s_band,$s_sngtitle) = split(/\t/,$line);

    $setlist .= "<TR><TD width=150 id=setlist>$s_time</TD>" .
	"<TD width=80 id=setlist>$s_dj</TD>" .
	"<TD id=setlist>$s_band</TD>" .
	"<TD id=setlist>$s_sngtitle</TD></TR>";
}

$setlist .= "</TR></TABLE>";
}

$text = $template->fill_in();

print $text;
print end_form;
print end_html;
