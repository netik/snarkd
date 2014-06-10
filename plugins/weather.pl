#!/usr/bin/perl

use Geo::WeatherNWS;
use Time::Local;
my $Report=Geo::WeatherNWS::new();

my $CACHEFILE = "/tmp/weather-cachefile";

#  If you want to change the server and user information, do it now.  This
#  step is not required.  If you dont call these functions, the module uses
#  the defaults.

#$Report->setservername("weather.noaa.gov");
#$Report->setusername("anonymous");
#$Report->setpassword('emailaddress@yourdomain.com');
#$Report->setdirectory("/data/observations/metar/stations");

# cache

my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
       $atime,$mtime,$ctime,$blksize,$blocks)
    = stat($CACHEFILE);

$cacheage = time() - $mtime;

($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime;

$ampm = "AM";
$year += 1900;
@days = ('Sun','Mon','Tue','Wed','Thu','Fri','Sat');

if ($hour>12) { $hour = $hour - 12; $ampm="PM" };

# only update once every 20 min
if ($cacheage > 1200) { 
    $Report->getreport('ksfo');

    open (F,">$CACHEFILE");

    if ($Report->{error})
    {
	print F "$Report->{errortext}";
    } else {
	print F "%%ASF Weather (as of " . $Report->{time}. "Z)\\n";
	print F "%%R" . $Report->{temperature_f} . "F ";
	print F $Report->{cloudcover} . "\\n";
	print F "Wind: %%R" .$Report->{winddirtext} . "%%G at %%R" .  $Report->{windspeedmph} . " MPH\\n";
	print F "Humidity: " .          $Report->{relative_humidity} . " %\\n";
    }
} 

open(F,"<$CACHEFILE");
while(<F>) { print $_ };
close(F);
  

