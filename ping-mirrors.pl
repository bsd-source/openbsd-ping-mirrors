#!/usr/bin/perl

use strict;
use warnings;

#
# ONLY OpenBSD modules included with the default installation are permitted!
#

use HTTP::Tiny;
use Net::Ping;
use Time::HiRes;

# Configuration hash (editable)
my %config = (
  'timeout'  => 1.0,    # How long to wait before giving up on server response, in seconds
  'debug'    => 1,      # Debug output?
  'top'      => 5,      # How many entries to return?
  'protocol' => 'tcp',  # tcp, udp, icmp, et al
  'port'     => 'http', # (used in getservbyname sub)
);

# hash to store servers and response times to protocol/port requests
my %serverstats;

# create HTTP::Tiny instance
my $http = HTTP::Tiny->new;

# Get a list of all current OpenBSD FTP servers
my $response = $http->get('http://ftp.openbsd.org/pub/OpenBSD/ftplist');
die "Failed!\n" unless $response->{success};

# Iterate through server list and get TCP/80 response time in ms
foreach my $line (split("\n", $response->{content})) {
  if ($line =~ /(http:\/\/)(.+?)(\/\S+)/) {
    my $response = &httping($2);
    $serverstats{$1.$2.$3} = $response if ($response);
  }
}

# Sort & print servers by response time in ms
my $i = 0;
print ("\n");
foreach my $key (sort {$serverstats{$a} <=> $serverstats{$b} } keys %serverstats) {
  $i++;
  print "$key\n";
  last if $i eq $config{'top'};
}

#
# Ping TCP/80 and return response time or 0 if unresponsive + some diagnostic output
#

sub httping ($) {
  my $host = shift;
  my $ping = Net::Ping->new($config{'protocol'});
  $ping->hires();
  $ping->{port_num} = getservbyname($config{'port'}, $config{'protocol'});
  print ("Trying $host... ") if $config{'debug'};
  my ($retval, $duration, $ip) = $ping->ping($host, $config{'timeout'});
  $ping->close();
  $duration = int($duration * 1000);

  if ($retval) {
    print ("$duration ms\n") if $config{'debug'};
    return $duration;
  } else {
    print ("unresponsive\n") if $config{'debug'};;
    return 0;
  }
}
