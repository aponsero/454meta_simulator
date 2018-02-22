use 5.010;
use strict;
use warnings;

use LWP::Simple;
use LWP::UserAgent;

my $nbReads = $ARGV[0];
my $profileLog=$ARGV[1];

my %profile;
my $fileexport="report.log";
my $total=0;

if (open(my $fhe, '>', $fileexport)) { 

if (open(my $fh, '<', $profileLog)) {
    while (my $row = <$fh>) {
        chomp $row;
        my @temp=split(/\t/, $row);
        if( not exists $profile{$temp[0]}){
             $profile{$temp[0]}=$temp[1];
             $total=$total+$temp[1];
        }else{
             print " two value found for $temp[0], only the fist one is taken into account\n";
        }

   }        
   
print "in total, $total reads where found in the profile\n";

my $offset=0;
foreach my $key (keys %profile){
   my $value = ($profile{$key}/$total)*$nbReads;
   my $rounded = int($value + 0.5);
   if($rounded ne 0){
   print $fhe "$key.fna;$value;$rounded;$offset\n";
   $offset=$offset+$rounded;
   }
}
print "In total, the simulator will produce Real_total=$offset reads\n";

}else {die "could not find $profileLog";}
}else {die "could not create $fileexport";}
