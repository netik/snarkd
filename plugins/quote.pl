#!/usr/bin/perl

# get a random quote

# load LWP library:
use LWP::UserAgent;

# define a URL
my $url = 'http://www.randomquotes.org/q.php';

# create UserAgent object
my $ua = new LWP::UserAgent;

# set a user agent (browser-id)
$ua->agent('Mozilla/5.5 (compatible; MSIE 5.5; Windows NT 5.1)');

# timeout:
$ua->timeout(5);

# proceed the request:
my $request = HTTP::Request->new('GET');
$request->url($url);

my $response = $ua->request($request);

# response code (like 200, 404, etc)
my $code = $response->code;

# headers (Server: Apache, Content-Type: text/html, ...)
my $headers = $response->headers_as_string;

# HTML body:
my $body =  $response->content;

($quote,$who) = split(/::/,$body);

$quote =~ s/\<.*\>//g;
$quote =~ s/\<//.*\>//g;

print "$quote - %%A$who\n";
